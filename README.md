# AstroYorumAI - Flutter Astrology App

## Backend API v2.1.2-stable

This repository contains a production-ready Flask API for natal chart calculations.

### API Endpoints

- `GET /health` - Health check endpoint
- `POST /natal` - Calculate natal chart from birth data

### Development

```bash
pip install -r requirements.txt
python astro_api.py
```

### Production Deployment

The API is configured for deployment on Render.com with the following files:
- `requirements.txt` - Python dependencies
- `Procfile` - Deployment configuration
- `astro_api.py` - Main Flask application

### Environment Variables

Create a `.env` file based on `.env.example`:
- `PORT` - Server port (default: 5000)
- `FLASK_ENV` - Environment (development/production)

### API Usage

Example request to `/natal` endpoint:

```json
{
  "date": "1990-01-15",
  "time": "10:30",
  "latitude": 41.0082,
  "longitude": 28.9784
}
```

Example response:

```json
{
  "planets": {
    "Sun": {"sign": "Capricorn", "deg": 24.5},
    "Moon": {"sign": "Gemini", "deg": 12.3}
  },
  "ascendant": "Gemini",
  "ascendant_deg": 68.1
}
```

### Flutter App

This is part of the AstroYorumAI Flutter application that provides:
- Natal chart calculations
- Astrology calendar
- User profiles and birth information
- Multi-language support (Turkish/English)
