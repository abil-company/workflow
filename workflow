export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { contactId, locationId } = req.body || {};

    if (!contactId) {
      return res.status(400).json({ error: 'contactId is required' });
    }

    // trava para a subconta certa
    if (locationId !== process.env.TARGET_LOCATION_ID) {
      return res.status(403).json({ error: 'Invalid locationId' });
    }

    const ghlRes = await fetch(
      `https://services.leadconnectorhq.com/contacts/${contactId}/workflow/${process.env.WORKFLOW_ID}`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.GHL_TOKEN}`,
          Version: '2021-07-28',
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      }
    );

    const text = await ghlRes.text();

    if (!ghlRes.ok) {
      return res.status(ghlRes.status).json({
        error: 'Failed to add contact to workflow',
        details: text,
      });
    }

    return res.status(200).json({
      ok: true,
      contactId,
    });
  } catch (err) {
    return res.status(500).json({
      error: 'Internal error',
      details: err.message || String(err),
    });
  }
}
