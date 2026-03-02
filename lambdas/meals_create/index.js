/**
 * POST /meals/create - Create a new meal
 */
const { PutCommand } = require('@aws-sdk/lib-dynamodb');
const { randomUUID } = require('crypto');
const { dynamo } = require('../common/dynamo');
const { success, error } = require('../common/response');
const { getUserId } = require('../common/auth');

const MEALS_TABLE = process.env.MEALS_TABLE_NAME;

exports.handler = async (event) => {
  try {
    const userId = getUserId(event);
    const body = JSON.parse(event.body || '{}');

    const { name, description, ingredients, tags, imageUrl } = body;
    if (!name) return error('name is required');

    const now = new Date().toISOString();
    const meal = {
      userId,
      mealId: randomUUID(),
      name,
      description: description || '',
      ingredients: ingredients || [],
      tags: tags || [],
      imageUrl: imageUrl || null,
      createdAt: now,
      updatedAt: now,
    };

    await dynamo.send(new PutCommand({ TableName: MEALS_TABLE, Item: meal }));

    return success({ meal }, 201);
  } catch (err) {
    console.error('meals_create error:', err);
    if (err.message?.includes('Unauthorized')) return error(err.message, 401);
    return error('Failed to create meal', 500);
  }
};
