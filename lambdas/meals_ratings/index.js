/**
 * GET /meals/ratings?mealId=xxx - Get all ratings for a meal
 */
const { QueryCommand } = require('@aws-sdk/lib-dynamodb');
const { dynamo } = require('../common/dynamo');
const { success, error } = require('../common/response');
const { getUserId } = require('../common/auth');

const MEAL_RATINGS_TABLE = process.env.MEAL_RATINGS_TABLE_NAME;

exports.handler = async (event) => {
  try {
    getUserId(event); // Verify auth (any authenticated user can view ratings)
    const mealId = event.queryStringParameters?.mealId;
    if (!mealId) return error('mealId query parameter is required');

    // Use GSI to query all ratings for a meal across users
    const result = await dynamo.send(new QueryCommand({
      TableName: MEAL_RATINGS_TABLE,
      IndexName: 'mealId-userId-index',
      KeyConditionExpression: 'mealId = :mealId',
      ExpressionAttributeValues: { ':mealId': mealId },
    }));

    const ratings = result.Items || [];
    const avgRating = ratings.length > 0
      ? ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length
      : null;

    return success({
      mealId,
      ratings,
      averageRating: avgRating ? Math.round(avgRating * 10) / 10 : null,
      totalRatings: ratings.length,
    });
  } catch (err) {
    console.error('meals_ratings error:', err);
    if (err.message?.includes('Unauthorized')) return error(err.message, 401);
    return error('Failed to fetch ratings', 500);
  }
};
