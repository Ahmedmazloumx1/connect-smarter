import io
import zipfile
from fastapi.testclient import TestClient
from backend.app import app, MAX_BYTES
from backend.analysis import analyze_text

client = TestClient(app)
def upload(name, data):
    return client.post('/analyze_cv', files={'file': (name, data)})

def test_health():
    assert client.get('/health').json()['status'] == 'ok'

def test_cv_extracts_only_present_skills():
    result = upload('../../cv.txt', b'Flutter developer with Dart, Firebase and Python experience.').json()
    assert {'flutter', 'dart', 'firebase', 'python'} <= set(result['skills'])
    assert 'docker' not in result['skills']

def test_docx():
    stream = io.BytesIO()
    with zipfile.ZipFile(stream, 'w') as archive:
        archive.writestr('word/document.xml', '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:r><w:t>Experienced Python developer building Django and FastAPI applications.</w:t></w:r></w:p></w:document>')
    assert upload('resume.docx', stream.getvalue()).status_code == 200

def test_empty_invalid_and_unsupported_files():
    assert upload('empty.txt', b'').status_code == 422
    assert upload('bad.pdf', b'not a pdf').status_code == 422
    assert upload('bad.docx', b'bad zip').status_code == 422
    assert upload('old.doc', b'old binary').status_code == 415
    assert upload('bad.txt', b'\xff' * 50).status_code == 422

def test_limit():
    assert upload('large.txt', b'x' * (MAX_BYTES + 1)).status_code == 413

def test_unknown_cv_does_not_invent_skills():
    result = analyze_text('A professional with experience in unrelated fields.')
    assert result['skills'] == []
    assert result['profile'] == 'General Professional'

def test_word_boundaries():
    assert 'java' not in analyze_text('JavaScript developer')['skills']

def test_repeatable_results():
    cv = 'Experienced Flutter developer, Dart and Firebase projects.'
    assert analyze_text(cv) == analyze_text(cv)

def test_cors_restricts_untrusted_origin():
    response = client.options('/analyze_cv', headers={'Origin': 'https://untrusted.invalid', 'Access-Control-Request-Method': 'POST'})
    assert response.status_code == 400

def test_body_limit_before_multipart_parsing():
    response = client.post('/analyze_cv', content=b'x' * (MAX_BYTES + 65537))
    assert response.status_code == 413

def test_chunked_body_cannot_bypass_size_limit():
    def chunks():
        for _ in range(7):
            yield b'x' * (1024 * 1024)
    assert client.post('/analyze_cv', content=chunks()).status_code == 413
