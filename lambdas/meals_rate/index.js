/**
 * POST /meals/rate - Rate a meal
 */
const { PutCommand } = require('@aws-sdk/lib-dynamodb');
const { dynamo } = require('../common/dynamo');
const { success, error } = require('../common/response');
const { getUserId } = require('../common/auth');

const MEAL_RATINGS_TABLE = process.env.MEAL_RATINGS_TABLE_NAME;

exports.handler = async (event) => {
  try {
    const userId = getUserId(event);
    const body = JSON.parse(event.body || '{}');

    const { mealId, rating, comment } = body;
    if (!mealId) return error('mealId is required');
    if (rating === undefined || rating < 1 || rating > 5) {
      return error('rating must be between 1 and 5');
    }

    const now = new Date().toISOString();
    const item = {
      userId,
      mealId,
      rating: Number(rating),
      comment: comment || '',
      createdAt: now,
      updatedAt: now,
    };

    await dynamo.send(new PutCommand({
      TableName: MEAL_RATINGS_TABLE,
      Item: item,
    }));

    return success({ rating: item }, 201);
  } catch (err) {
    console.error('meals_rate error:', err);
    if (err.message?.includes('Unauthorized')) return error(err.message, 401);
    return error('Failed to rate meal', 500);
  }
};
