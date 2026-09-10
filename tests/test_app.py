import pytest
from app import app, limiter
from unittest.mock import patch

@pytest.fixture
def client():
    app.config['TESTING'] = True
    limiter.reset()
    with app.test_client() as client:
        yield client
    limiter.reset()

def test_download_missing_url(client):
    response = client.post('/api/download', json={'format': 'video'})
    assert response.status_code == 400
    assert response.get_json()['error'] == 'No URL provided'

def test_download_empty_url(client):
    response = client.post('/api/download', json={'url': '  '})
    assert response.status_code == 400
    assert response.get_json()['error'] == 'No URL provided'

def test_download_no_json(client):
    # Flask's request.json will be None if no JSON body is provided
    response = client.post('/api/download', content_type='application/json')
    assert response.status_code == 400
    assert response.get_json()['error'] == 'No URL provided'

def test_download_valid(client):
    with patch('threading.Thread') as mock_thread:
        response = client.post('/api/download', json={'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'})
        assert response.status_code == 200
        assert 'job_id' in response.get_json()
        assert mock_thread.called

def test_download_rate_limited(client):
    with patch('threading.Thread'):
        for _ in range(10):
            response = client.post('/api/download', json={'url': 'https://example.com/video'})
            assert response.status_code == 200

    response = client.post('/api/download', json={'url': 'https://example.com/video'})
    assert response.status_code == 429
