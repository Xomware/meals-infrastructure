/**
 * Extract userId from the authorizer context.
 * The Lambda authorizer sets context.userId after validating the token.
 */
const getUserId = (event) => {
  const userId = event.requestContext?.authorizer?.userId;
  if (!userId) {
    throw new Error('Unauthorized: no userId in authorizer context');
  }
  return userId;
};

module.exports = { getUserId };
