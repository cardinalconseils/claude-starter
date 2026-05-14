const fs = require('fs');
const https = require('https');
const path = require('path');

const PROJECT_ID = 'PVT_kwHOCtKzxM4BXt3x';
const STATUS_FIELD_ID = 'PVTSSF_lAHOCtKzxM4BXt3xzhS42H8';
const PHASE_NUMBER_FIELD_ID = 'PVTF_lAHOCtKzxM4BXt3xzhS42P0';
const RUNNER_STATE_FIELD_ID = 'PVTF_lAHOCtKzxM4BXt3xzhS42P4';
const PR_COUNT_FIELD_ID = 'PVTF_lAHOCtKzxM4BXt3xzhS42Qw';
const LAST_SYNC_FIELD_ID = 'PVTF_lAHOCtKzxM4BXt3xzhS42Q0';

const STATUS_COLUMN_MAP = {
  'Backlog': 'ad49b1dc', 'Ready': 'f48c9e53', 'In Progress': '8162feba',
  'In Review': 'bf076149', 'Blocked': 'a692d1d4', 'Done': '6bdb640c'
};

let configCache = null;

class GitHubUnreachableError extends Error {
  constructor(message) {
    super(message);
    this.name = 'GitHubUnreachableError';
  }
}

function loadConfig() {
  if (configCache) return configCache;
  const pluginJsonPath = path.join(path.dirname(__dirname), '.claude-plugin', 'plugin.json');
  try {
    const content = fs.readFileSync(pluginJsonPath, 'utf-8');
    configCache = JSON.parse(content);
  } catch (err) {}
  return configCache;
}

function isConfigured() {
  const config = loadConfig();
  if (!config || !config.github_project) return false;
  const { owner, repo, number } = config.github_project;
  return !!owner && !!repo && number > 0;
}

async function executeGraphQL(query) {
  return new Promise((resolve, reject) => {
    const token = process.env.GITHUB_TOKEN;
    if (!token) {
      reject(new GitHubUnreachableError('GITHUB_TOKEN not set'));
      return;
    }
    const payload = JSON.stringify({ query });
    const options = {
      hostname: 'api.github.com', path: '/graphql', method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload), 'User-Agent': 'CKS-GitHub-Sync'
      }
    };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          if (parsed.errors) reject(new GitHubUnreachableError(`GraphQL: ${JSON.stringify(parsed.errors)}`));
          else resolve(parsed.data);
        } catch (err) {
          reject(new GitHubUnreachableError(`Parse: ${err.message}`));
        }
      });
    });
    req.on('error', (err) => {
      reject(new GitHubUnreachableError(`Network: ${err.message}`));
    });
    req.write(payload);
    req.end();
  });
}

async function getPhaseItems() {
  if (!isConfigured()) return [];
  const query = `{node(id:"${PROJECT_ID}"){...on ProjectV2{items(first:20){edges{node{id content{...on DraftIssue{id title url}}fieldValues(first:10){edges{node{...on ProjectV2ItemFieldValueNumber{field{...on ProjectV2Field{id name}}number}...on ProjectV2ItemFieldValueSingleSelect{field{...on ProjectV2Field{id name}}name}...on ProjectV2ItemFieldValueText{field{...on ProjectV2Field{id name}}text}}}}}}}}}}}}`;
  try {
    const result = await executeGraphQL(query);
    if (!result?.node) return [];
    const items = result.node.items.edges.map((edge) => {
      const node = edge.node;
      const content = node.content;
      let phaseNumber = 0, statusColumn = 'Backlog';
      node.fieldValues.edges.forEach((fv) => {
        const field = fv.node.field;
        if (field.id === PHASE_NUMBER_FIELD_ID && fv.node.number !== undefined) phaseNumber = fv.node.number;
        if (field.id === STATUS_FIELD_ID && fv.node.name) statusColumn = fv.node.name;
      });
      return { id: node.id, phaseNumber, title: content?.title || 'Untitled', column: statusColumn, labels: [], url: content?.url || '' };
    });
    return items.filter(item => item.phaseNumber >= 0 && item.phaseNumber <= 8);
  } catch (err) { return []; }
}

async function moveCard(itemId, toColumn) {
  if (!isConfigured()) return;
  const optionId = STATUS_COLUMN_MAP[toColumn];
  if (!optionId) throw new GitHubUnreachableError(`Unknown column: ${toColumn}`);
  const query = `mutation{updateProjectV2ItemFieldValue(input:{projectId:"${PROJECT_ID}" itemId:"${itemId}" fieldId:"${STATUS_FIELD_ID}" value:{singleSelectOptionId:"${optionId}"}}){projectV2Item{id}}}`;
  await executeGraphQL(query);
}

async function setCustomField(itemId, fieldName, value) {
  if (!isConfigured()) return;
  const fieldMap = { 'phase_number': PHASE_NUMBER_FIELD_ID, 'runner_state': RUNNER_STATE_FIELD_ID, 'pr_count': PR_COUNT_FIELD_ID, 'last_sync': LAST_SYNC_FIELD_ID };
  const fieldId = fieldMap[fieldName];
  if (!fieldId) throw new GitHubUnreachableError(`Unknown field: ${fieldName}`);
  const isNumber = fieldName === 'phase_number' || fieldName === 'pr_count';
  const valueBlock = isNumber ? `number:${value}` : `text:"${String(value).replace(/"/g, '\\"')}"`;
  const query = `mutation{updateProjectV2ItemFieldValue(input:{projectId:"${PROJECT_ID}" itemId:"${itemId}" fieldId:"${fieldId}" value:{${valueBlock}}}){projectV2Item{id}}}`;
  await executeGraphQL(query);
}

async function commentOnPhaseItem(itemId, body) {
  if (!isConfigured()) return;
  const query = `mutation{addComment(input:{subjectId:"${itemId}" body:"${body.replace(/"/g, '\\"')}"}){commentEdge{node{id}}}}`;
  await executeGraphQL(query);
}

/**
 * Query closed Phase items (prior art for discovery)
 */
async function getPriorArt() {
  if (!isConfigured()) return [];

  const query = `
    {
      node(id: "${PROJECT_ID}") {
        ... on ProjectV2 {
          items(first: 20, filter: { direction: ASC, field: UPDATED_AT }) {
            edges {
              node {
                id
                content {
                  ... on DraftIssue {
                    id
                    title
                    url
                  }
                }
                fieldValues(first: 10) {
                  edges {
                    node {
                      ... on ProjectV2ItemFieldValueSingleSelect {
                        field { ... on ProjectV2Field { id } }
                        name
                      }
                      ... on ProjectV2ItemFieldValueNumber {
                        field { ... on ProjectV2Field { id } }
                        number
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  `;

  try {
    const result = await executeGraphQL(query);
    if (!result || !result.node) return [];

    const items = result.node.items.edges
      .map((edge) => {
        const node = edge.node;
        const content = node.content;
        const title = content?.title || 'Untitled';
        const url = content?.url || '';

        let statusColumn = 'Backlog';
        let phaseNumber = 0;

        node.fieldValues.edges.forEach((fv) => {
          const field = fv.node.field;
          if (field.id === STATUS_FIELD_ID && fv.node.name) {
            statusColumn = fv.node.name;
          }
          if (field.id === PHASE_NUMBER_FIELD_ID && fv.node.number !== undefined) {
            phaseNumber = fv.node.number;
          }
        });

        return {
          id: node.id,
          phaseNumber,
          title,
          column: statusColumn,
          labels: [],
          url
        };
      })
      .filter(item => item.column === 'Done' && item.phaseNumber >= 0 && item.phaseNumber <= 8);

    return items;
  } catch (err) {
    return [];
  }
}

module.exports = {
  isConfigured,
  getPhaseItems,
  moveCard,
  setCustomField,
  commentOnPhaseItem,
  getPriorArt,
  GitHubUnreachableError
};
