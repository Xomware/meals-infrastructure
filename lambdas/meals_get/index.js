/**
 * GET /meals/get?mealId=xxx - Get a single meal by ID
 */
const { GetCommand } = require('@aws-sdk/lib-dynamodb');
const { dynamo } = require('../common/dynamo');
const { success, error } = require('../common/response');
const { getUserId } = require('../common/auth');

const MEALS_TABLE = process.env.MEALS_TABLE_NAME;

exports.handler = async (event) => {
  try {
    const userId = getUserId(event);
    const mealId = event.queryStringParameters?.mealId;
    if (!mealId) return error('mealId query parameter is required');

    const result = await dynamo.send(new GetCommand({
      TableName: MEALS_TABLE,
      Key: { userId, mealId },
    }));

    if (!result.Item) return error('Meal not found', 404);

    return success({ meal: result.Item });
  } catch (err) {
    console.error('meals_get error:', err);
    if (err.message?.includes('Unauthorized')) return error(err.message, 401);
    return error('Failed to fetch meal', 500);
  }
};
