#!/bin/bash

API_PATH="src/api/magazine"

echo "Creating folders..."
mkdir -p $API_PATH/content-types/magazine
mkdir -p $API_PATH/controllers
mkdir -p $API_PATH/services
mkdir -p $API_PATH/routes

echo "Creating schema..."

cat > $API_PATH/content-types/magazine/schema.json <<EOF
{
  "kind": "collectionType",
  "collectionName": "magazines",
  "info": {
    "singularName": "magazine",
    "pluralName": "magazines",
    "displayName": "Magazine"
  },
  "options": { "draftAndPublish": true },
  "attributes": {
    "title": { "type": "string", "required": true },
    "slug": { "type": "uid", "targetField": "title" },
    "issue": { "type": "string" },
    "excerpt": { "type": "text" },

    "cover_image": {
      "type": "media",
      "multiple": false,
      "allowedTypes": ["images"]
    },

    "pdf_file": {
      "type": "media",
      "multiple": false,
      "allowedTypes": ["files"]
    },

    "is_highlight": { "type": "boolean", "default": false },
    "is_trending": { "type": "boolean", "default": false }
  }
}
EOF

echo "Creating controller..."

cat > $API_PATH/controllers/magazine.js <<EOF
"use strict";

const { createCoreController } = require("@strapi/strapi").factories;

module.exports = createCoreController("api::magazine.magazine", ({ strapi }) => ({

  async find(ctx) {

    const { page = 1, pageSize = 20 } = ctx.query;

    const { results, pagination } = await strapi
      .service("api::magazine.magazine")
      .find({
        populate: {
          cover_image: true,
          pdf_file: true
        },
        sort: { createdAt: "desc" },
        pagination: {
          page: Number(page),
          pageSize: Number(pageSize)
        }
      });

    return {
      data: results,
      meta: { pagination }
    };
  }

}));
EOF

echo "Creating service..."

cat > $API_PATH/services/magazine.js <<EOF
"use strict";

const { createCoreService } = require("@strapi/strapi").factories;

module.exports = createCoreService("api::magazine.magazine");
EOF

echo "Creating routes..."

cat > $API_PATH/routes/magazine.js <<EOF
"use strict";

const { createCoreRouter } = require("@strapi/strapi").factories;

module.exports = createCoreRouter("api::magazine.magazine");
EOF

echo "Done. Run:"
echo "npm run build && npm run develop"