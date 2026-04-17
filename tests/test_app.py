import pytest
from app import app
from unittest.mock import patch

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

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
