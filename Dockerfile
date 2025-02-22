#Install dependencies 
FROM node:19-bullseye-slim AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci 

#Rebuild the source code 
FROM node:19-bullseye-slim AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build

#Production image, copy all the files and run next
FROM node:19-bullseye-slim AS runner
WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

EXPOSE 3000

CMD ["npm", "start"]
