import io
import zipfile
import pytest
from pypdf import PdfWriter
from pypdf.generic import DecodedStreamObject, DictionaryObject, NameObject
from backend.analysis import extract_text, MAX_EXPANDED

def pdf_bytes(text=None, encrypted=False, pages=1):
    writer = PdfWriter()
    for _ in range(pages):
        page = writer.add_blank_page(width=600, height=800)
        if text:
            font = DictionaryObject({NameObject('/Type'): NameObject('/Font'), NameObject('/Subtype'): NameObject('/Type1'), NameObject('/BaseFont'): NameObject('/Helvetica')})
            page[NameObject('/Resources')] = DictionaryObject({NameObject('/Font'): DictionaryObject({NameObject('/F1'): writer._add_object(font)})})
            stream = DecodedStreamObject()
            stream.set_data(f'BT /F1 12 Tf 50 700 Td ({text}) Tj ET'.encode())
            page[NameObject('/Contents')] = writer._add_object(stream)
    if encrypted:
        writer.encrypt('private')
    out=io.BytesIO(); writer.write(out)
    return out.getvalue()

def test_real_text_pdf():
    text='Experienced Python developer using FastAPI and SQL for web applications.'
    assert 'FastAPI' in extract_text(pdf_bytes(text), '.pdf')

@pytest.mark.parametrize('data,expected', [
    (pdf_bytes(), 'No readable'),
    (pdf_bytes(encrypted=True), 'password'),
    (pdf_bytes(pages=31), '30 pages'),
])
def test_pdf_failures_are_explained(data, expected):
    with pytest.raises(ValueError, match=expected):
        extract_text(data, '.pdf')

def test_expanded_docx_limit():
    out=io.BytesIO()
    with zipfile.ZipFile(out,'w',compression=zipfile.ZIP_DEFLATED) as archive:
        archive.writestr('word/document.xml', b'x' * (MAX_EXPANDED + 1))
    with pytest.raises(ValueError, match='Expanded'):
        extract_text(out.getvalue(), '.docx')

def test_docx_split_text_runs_are_joined():
    out=io.BytesIO()
    with zipfile.ZipFile(out,'w') as archive:
        archive.writestr('word/document.xml', '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:r><w:t>Experienced Flut</w:t></w:r><w:r><w:t>ter developer with Firebase and Dart.</w:t></w:r></w:p></w:document>')
    assert 'Flutter' in extract_text(out.getvalue(), '.docx')
