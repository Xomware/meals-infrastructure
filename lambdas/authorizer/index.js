/**
 * Lambda Authorizer - Token-based
 * Validates Bearer token from Authorization header.
 * Sets userId in authorizer context for downstream lambdas.
 */
const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');

const ssm = new SSMClient({ region: process.env.AWS_REGION || 'us-east-1' });
const APP_NAME = process.env.APP_NAME || 'meals';

let cachedSecretKey = null;

const getSecretKey = async () => {
  if (cachedSecretKey) return cachedSecretKey;
  const result = await ssm.send(new GetParameterCommand({
    Name: `/${APP_NAME}/api/API_SECRET_KEY`,
    WithDecryption: true,
  }));
  cachedSecretKey = result.Parameter.Value;
  return cachedSecretKey;
};

exports.handler = async (event) => {
  const token = event.authorizationToken?.replace('Bearer ', '');
  if (!token) {
    throw new Error('Unauthorized');
  }

  try {
    const secretKey = await getSecretKey();

    // Decode JWT (simple base64 decode - replace with proper JWT verification in production)
    const parts = token.split('.');
    if (parts.length !== 3) throw new Error('Invalid token format');

    const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString());
    const userId = payload.sub || payload.userId || payload.email;

    if (!userId) throw new Error('No userId in token');

    return {
      principalId: userId,
      policyDocument: {
        Version: '2012-10-17',
        Statement: [{
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: event.methodArn.split('/').slice(0, 2).join('/') + '/*',
        }],
      },
      context: { userId },
    };
  } catch (err) {
    console.error('Authorization failed:', err.message);
    throw new Error('Unauthorized');
  }
};
