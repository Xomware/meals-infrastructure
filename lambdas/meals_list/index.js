/**
 * GET /meals/list - Get all meals for the authenticated user
 */
const { QueryCommand } = require('@aws-sdk/lib-dynamodb');
const { dynamo } = require('../common/dynamo');
const { success, error } = require('../common/response');
const { getUserId } = require('../common/auth');

const MEALS_TABLE = process.env.MEALS_TABLE_NAME;

exports.handler = async (event) => {
  try {
    const userId = getUserId(event);

    const result = await dynamo.send(new QueryCommand({
      TableName: MEALS_TABLE,
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: { ':userId': userId },
    }));

    return success({ meals: result.Items || [] });
  } catch (err) {
    console.error('meals_list error:', err);
    if (err.message?.includes('Unauthorized')) return error(err.message, 401);
    return error('Failed to fetch meals', 500);
  }
};
