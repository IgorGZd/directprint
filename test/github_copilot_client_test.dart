import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:directprint/directprint.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Minimal fake HTTP client used to intercept outgoing requests in tests.
// ---------------------------------------------------------------------------

typedef _RequestHandler = Future<http.Response> Function(http.BaseRequest);

class _FakeHttpClient extends http.BaseClient {
  final _RequestHandler handler;

  _FakeHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

const _fakeGitHubToken = 'ghp_test_token';
const _fakeCopilotToken = 'eyJhbGciOiJFUzI1NiJ9.fake';

const _tokenUrl = 'https://api.github.com/copilot_internal/v2/token';
const _chatUrl = 'https://api.githubcopilot.com/chat/completions';

http.Response _tokenSuccessResponse() => http.Response(
      jsonEncode({'token': _fakeCopilotToken, 'expires_at': '9999999999'}),
      200,
      headers: {'content-type': 'application/json'},
    );

http.Response _chatSuccessResponse(String content) => http.Response(
      jsonEncode({
        'id': 'chatcmpl-123',
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': content},
            'finish_reason': 'stop',
          }
        ],
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── CopilotMessage ──────────────────────────────────────────────────────

  group('CopilotMessage', () {
    test('toJson returns correct map', () {
      const message = CopilotMessage(role: 'user', content: 'Hello!');
      expect(message.toJson(), {'role': 'user', 'content': 'Hello!'});
    });
  });

  // ── CopilotChoice ───────────────────────────────────────────────────────

  group('CopilotChoice', () {
    test('fromJson parses correctly', () {
      final json = {
        'index': 0,
        'message': {'role': 'assistant', 'content': 'Hi there!'},
        'finish_reason': 'stop',
      };
      final choice = CopilotChoice.fromJson(json);
      expect(choice.index, 0);
      expect(choice.message.role, 'assistant');
      expect(choice.message.content, 'Hi there!');
      expect(choice.finishReason, 'stop');
    });

    test('fromJson handles null finish_reason', () {
      final json = {
        'index': 1,
        'message': {'role': 'assistant', 'content': 'response'},
        'finish_reason': null,
      };
      final choice = CopilotChoice.fromJson(json);
      expect(choice.finishReason, isNull);
    });
  });

  // ── CopilotResponse ─────────────────────────────────────────────────────

  group('CopilotResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'chatcmpl-abc',
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': 'Hello'},
            'finish_reason': 'stop',
          },
        ],
      };
      final response = CopilotResponse.fromJson(json);
      expect(response.id, 'chatcmpl-abc');
      expect(response.choices.length, 1);
      expect(response.choices.first.message.content, 'Hello');
    });
  });

  // ── GitHubCopilotException ──────────────────────────────────────────────

  group('GitHubCopilotException', () {
    test('toString includes message and status code when present', () {
      const ex = GitHubCopilotException('Something failed', statusCode: 401);
      expect(ex.toString(),
          'GitHubCopilotException: Something failed (HTTP 401)');
    });

    test('toString without status code', () {
      const ex = GitHubCopilotException('Network error');
      expect(ex.toString(), 'GitHubCopilotException: Network error');
    });
  });

  // ── GitHubCopilotClient ─────────────────────────────────────────────────

  group('GitHubCopilotClient', () {
    test('chat returns CopilotResponse on success', () async {
      final fakeClient = _FakeHttpClient((request) async {
        if (request.url.toString() == _tokenUrl) {
          return _tokenSuccessResponse();
        }
        if (request.url.toString() == _chatUrl) {
          return _chatSuccessResponse('Hello from Copilot!');
        }
        return http.Response('Not found', 404);
      });

      final client = GitHubCopilotClient(
        githubToken: _fakeGitHubToken,
        httpClient: fakeClient,
      );

      final response = await client.chat([
        const CopilotMessage(role: 'user', content: 'Hello!'),
      ]);

      expect(response.id, 'chatcmpl-123');
      expect(response.choices.first.message.content, 'Hello from Copilot!');
      client.close();
    });

    test('chat sends Authorization header with copilot token', () async {
      String? capturedAuthHeader;

      final fakeClient = _FakeHttpClient((request) async {
        if (request.url.toString() == _tokenUrl) {
          return _tokenSuccessResponse();
        }
        if (request.url.toString() == _chatUrl) {
          capturedAuthHeader = request.headers['Authorization'];
          return _chatSuccessResponse('OK');
        }
        return http.Response('Not found', 404);
      });

      final client = GitHubCopilotClient(
        githubToken: _fakeGitHubToken,
        httpClient: fakeClient,
      );

      await client.chat([const CopilotMessage(role: 'user', content: 'Hi')]);

      expect(capturedAuthHeader, 'Bearer $_fakeCopilotToken');
      client.close();
    });

    test('chat sends GitHub token when fetching copilot token', () async {
      String? capturedAuthHeader;

      final fakeClient = _FakeHttpClient((request) async {
        if (request.url.toString() == _tokenUrl) {
          capturedAuthHeader = request.headers['Authorization'];
          return _tokenSuccessResponse();
        }
        return _chatSuccessResponse('OK');
      });

      final client = GitHubCopilotClient(
        githubToken: _fakeGitHubToken,
        httpClient: fakeClient,
      );

      await client.chat([const CopilotMessage(role: 'user', content: 'Hi')]);

      expect(capturedAuthHeader, 'token $_fakeGitHubToken');
      client.close();
    });

    test('chat throws GitHubCopilotException when token request fails',
        () async {
      final fakeClient = _FakeHttpClient((request) async {
        if (request.url.toString() == _tokenUrl) {
          return http.Response('Unauthorized', 401);
        }
        return http.Response('Not found', 404);
      });

      final client = GitHubCopilotClient(
        githubToken: 'invalid_token',
        httpClient: fakeClient,
      );

      expect(
        () => client.chat(
            [const CopilotMessage(role: 'user', content: 'Hello')]),
        throwsA(isA<GitHubCopilotException>().having(
          (e) => e.statusCode,
          'statusCode',
          401,
        )),
      );
      client.close();
    });

    test('chat throws GitHubCopilotException when chat request fails',
        () async {
      final fakeClient = _FakeHttpClient((request) async {
        if (request.url.toString() == _tokenUrl) {
          return _tokenSuccessResponse();
        }
        return http.Response('Internal server error', 500);
      });

      final client = GitHubCopilotClient(
        githubToken: _fakeGitHubToken,
        httpClient: fakeClient,
      );

      await expectLater(
        client.chat([const CopilotMessage(role: 'user', content: 'Hello')]),
        throwsA(isA<GitHubCopilotException>().having(
          (e) => e.statusCode,
          'statusCode',
          500,
        )),
      );
      client.close();
    });

    test('chat uses provided model parameter', () async {
      String? capturedModel;

      final fakeClient = _FakeHttpClient((request) async {
        if (request.url.toString() == _tokenUrl) {
          return _tokenSuccessResponse();
        }
        if (request.url.toString() == _chatUrl) {
          final body =
              jsonDecode((request as http.Request).body) as Map<String, dynamic>;
          capturedModel = body['model'] as String?;
          return _chatSuccessResponse('OK');
        }
        return http.Response('Not found', 404);
      });

      final client = GitHubCopilotClient(
        githubToken: _fakeGitHubToken,
        httpClient: fakeClient,
      );

      await client.chat(
        [const CopilotMessage(role: 'user', content: 'Hi')],
        model: 'gpt-3.5-turbo',
      );

      expect(capturedModel, 'gpt-3.5-turbo');
      client.close();
    });

    test('chat uses default model when not specified', () async {
      String? capturedModel;

      final fakeClient = _FakeHttpClient((request) async {
        if (request.url.toString() == _tokenUrl) {
          return _tokenSuccessResponse();
        }
        if (request.url.toString() == _chatUrl) {
          final body =
              jsonDecode((request as http.Request).body) as Map<String, dynamic>;
          capturedModel = body['model'] as String?;
          return _chatSuccessResponse('OK');
        }
        return http.Response('Not found', 404);
      });

      final client = GitHubCopilotClient(
        githubToken: _fakeGitHubToken,
        httpClient: fakeClient,
      );

      await client.chat([const CopilotMessage(role: 'user', content: 'Hi')]);

      expect(capturedModel, GitHubCopilotClient.defaultModel);
      client.close();
    });
  });
}
