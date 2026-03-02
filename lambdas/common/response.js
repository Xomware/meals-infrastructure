const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Authorization,Content-Type',
};

const success = (body, statusCode = 200) => ({
  statusCode,
  headers,
  body: JSON.stringify(body),
});

const error = (message, statusCode = 400) => ({
  statusCode,
  headers,
  body: JSON.stringify({ error: message }),
});

module.exports = { success, error };
