const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager();

let cachedSecret = null;
let cacheExpiry = 0;

async function getSecret(secretName) {
  if (cachedSecret && Date.now() < cacheExpiry) {
    return cachedSecret;
  }

  const result = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
  cachedSecret = JSON.parse(result.SecretString);
  cacheExpiry = Date.now() + 5 * 60 * 1000;
  return cachedSecret;
}

exports.handler = async (event) => {
  const dbSecrets = await getSecret('prod/database/credentials');
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Loaded secrets successfully',
      dbUser: dbSecrets.username,
      secretId: dbSecrets.host
    })
  };
};
