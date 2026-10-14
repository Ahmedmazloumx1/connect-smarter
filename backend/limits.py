"""Bound multipart input before the parser can spool unbounded uploads."""
from starlette.responses import JSONResponse

class BodyLimitMiddleware:
    def __init__(self, app, limit=5 * 1024 * 1024 + 65536):
        self.app = app
        self.limit = limit

    async def __call__(self, scope, receive, send):
        if scope['type'] != 'http' or scope['path'] != '/analyze_cv':
            return await self.app(scope, receive, send)
        headers = dict(scope.get('headers', []))
        try:
            declared = int(headers.get(b'content-length', b'0'))
        except ValueError:
            declared = 0
        async def reject():
            await JSONResponse({'detail': 'Maximum CV size is 5 MB.'}, status_code=413)(scope, receive, send)
        if declared > self.limit:
            return await reject()
        messages = []
        total = 0
        while True:
            message = await receive()
            if message['type'] == 'http.disconnect': return
            total += len(message.get('body', b''))
            if total > self.limit: return await reject()
            messages.append(message)
            if not message.get('more_body', False): break
        iterator = iter(messages)
        async def replay():
            try: return next(iterator)
            except StopIteration: return await receive()
        await self.app(scope, replay, send)
