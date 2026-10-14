"""Deterministic CV extraction; never infers absent skills."""
import io
import json
import re
import zipfile
from pathlib import Path
from defusedxml import ElementTree
from pypdf import PdfReader

SKILL_BANKS = json.loads(Path(__file__).with_name('skills.json').read_text())
MAX_TEXT = 250_000
MAX_EXPANDED = 20 * 1024 * 1024

def extract_text(data: bytes, extension: str) -> str:
    if extension == '.txt':
        text = data.decode('utf-8-sig')
    elif extension == '.pdf':
        if not data.startswith(b'%PDF-'):
            raise ValueError('The file is not a valid PDF.')
        reader = PdfReader(io.BytesIO(data))
        if reader.is_encrypted:
            raise ValueError('Upload a PDF without password protection.')
        if len(reader.pages) > 30:
            raise ValueError('CVs must contain at most 30 pages.')
        chunks = []
        for page in reader.pages:
            content = page.get_contents()
            if content and len(content.get_data()) > MAX_EXPANDED:
                raise ValueError('PDF content is too large.')
            chunks.append(page.extract_text() or '')
            if sum(map(len, chunks)) > MAX_TEXT:
                raise ValueError('CV text is too long.')
        text = '\n'.join(chunks)
    elif extension == '.docx':
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            if sum(i.file_size for i in archive.infolist()) > MAX_EXPANDED:
                raise ValueError('Expanded document is too large.')
            document = ElementTree.fromstring(archive.read('word/document.xml'))
            ns = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
            text = '\n'.join(''.join(p.itertext()) for p in document.iter(ns + 'p'))
    else:
        raise ValueError('Use PDF, DOCX or UTF-8 TXT.')
    text = re.sub(r'\s+', ' ', text).strip()
    if len(text) < 30:
        raise ValueError('No readable CV text found. Scanned PDFs require OCR; export a text PDF instead.')
    if len(text) > MAX_TEXT:
        raise ValueError('CV text is too long.')
    return text

def has_skill(text: str, skill: str) -> bool:
    return bool(re.search(r'(?<!\w)' + re.escape(skill) + r'(?!\w)', text, re.I))

def analyze_text(text: str) -> dict:
    matches = {role: [skill for skill in skills if has_skill(text, skill)] for role, skills in SKILL_BANKS.items()}
    role = max(matches, key=lambda name: len(matches[name]))
    skills = sorted({skill for found in matches.values() for skill in found})
    profile = role.title() if matches[role] else 'General Professional'
    return {'profile': profile, 'skills': skills,
        'matchReason': f'{len(skills)} explicit skills found in your document. Suggested profile: {profile}. This is keyword-based guidance; review the extracted skills.',
        'method': 'keyword-coverage-v1'}
