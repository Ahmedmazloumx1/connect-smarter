"""Compatibility entry point: python api.py or uvicorn api:app."""
from backend.app import app

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
