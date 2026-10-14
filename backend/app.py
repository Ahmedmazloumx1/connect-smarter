"""Local CV service. No uploaded files or extracted content are retained."""
import os
from pathlib import Path
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from starlette.concurrency import run_in_threadpool
from .analysis import analyze_text, extract_text
from .limits import BodyLimitMiddleware

MAX_BYTES = 5 * 1024 * 1024
app = FastAPI(title='Connect Smarter', version='1.0.0')
app.add_middleware(BodyLimitMiddleware)
app.add_middleware(CORSMiddleware,
    allow_origins=[v.strip() for v in os.getenv('ALLOWED_ORIGINS', 'http://localhost:3000,http://127.0.0.1:3000').split(',') if v.strip()],
    allow_credentials=False, allow_methods=['GET', 'POST'], allow_headers=['Content-Type'])

@app.get('/health')
@app.get('/status')
def health():
    return {'status': 'ok', 'analysisMethod': 'keyword-coverage-v1'}

@app.post('/analyze_cv')
async def analyze_cv(file: UploadFile = File(...)):
    try:
        suffix = Path(file.filename or '').suffix.lower()
        if suffix not in {'.pdf', '.docx', '.txt'}:
            raise HTTPException(415, 'Use PDF, DOCX or UTF-8 TXT files.')
        data = await file.read(MAX_BYTES + 1)
        if len(data) > MAX_BYTES:
            raise HTTPException(413, 'Maximum CV size is 5 MB.')
        if not data:
            raise HTTPException(422, 'The file is empty.')
        try:
            text = await run_in_threadpool(extract_text, data, suffix)
        except Exception as error:
            detail = str(error) if isinstance(error, ValueError) else 'Unable to read this document. Export it as a text PDF, DOCX or UTF-8 TXT.'
            raise HTTPException(422, detail) from error
        return analyze_text(text)
    finally:
        await file.close()
