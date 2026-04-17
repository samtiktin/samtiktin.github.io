# Verifier Backend Starter

This folder is a starter backend for the `Verify a Supplier` feature.

What it does:

- accepts a supplier URL
- fetches the supplier page
- checks visible trust signals
- sends the extracted page text to OpenAI for a structured review
- returns a score and notes to the frontend

Suggested deployment:

1. Put this folder in GitHub
2. Import the repo into Vercel
3. Set the Vercel root directory to `verifier-backend`
4. Add the `OPENAI_API_KEY` environment variable
5. Deploy
6. Point the frontend `verify/verify.js` endpoint to your deployed API URL

Expected endpoint:

- `POST /api/verify`

Request body:

```json
{
  "url": "https://example.com",
  "notes": "optional focus notes"
}
```

Response shape:

```json
{
  "label": "Strong visible signals",
  "band": "Strong",
  "score": 78,
  "summary": "Short summary",
  "found": ["..."],
  "missing": ["..."],
  "notes": ["..."]
}
```
