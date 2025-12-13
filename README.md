# RoomPilot

## Mantis Template
### 1. Setup
```
npm install
npm run dev
```

### 2. Fix JWEDecryptionFailed error
- Set `axiosServices` `baseURL` to `''` in `axios.ts`

### 3. Create local PostgreSQL database
```
// Create an app user
CREATE USER meeting_user WITH PASSWORD 'meeting_password';

// Create the app database, owned by that user
CREATE DATABASE meeting_db OWNER meeting_user;

// Ensure meeting_user has full access to created database
GRANT ALL PRIVILEGES ON DATABASE meeting_db TO meeting_user;

// Allow meeting_user to create database
ALTER ROLE meeting_user CREATEDB;

// Exit psql
\q
```

### 4. Add Prisma
- Install dependencies
```
npm install prisma --save-dev
npm install @prisma/client @next-auth/prisma-adapter
```

- Set DATABASE_URL
- Create minimal schema in `prisma/schema.prisma`

- Create Prisma client
```
npx prisma migrate dev --name init
```

- Add this line in prisma.config.ts to fix missing required environemnt variable bug:
```
import "dotenv/config";
```

- Create a singleton Prisma client in `src/lib/prisma.ts`

### 5. Integrate Prisma into existing codebase
- Install dependencies
```
npm install bcryptjs
```
- Change `src/utils/authOptions.ts` to use Prisma instead of axios
for back-end logic

- Change `prisma/schema.prisma` to include necessary NextAuth models

### 6. Fix "@prisma/client did not initialize yet" bug
- Create Prisma debug script in `scripts/check-prisma.cjs`
- Change `schema.prisma` to use `prisma-client-js` as `provider` and no `src` value

### 7. Address 404 response for GET request to /api/menu/dashboard
- Comment out menu/dashboard preload call in AuthLogin

### 8. Add logic for distinction between admin and normal users
- Change `authOptions` to redirect based on `ROLE`
Add placeholder pages for `admin/bookings/room` and `user/bookings/new`
- Change `APP_DEFUALT_PATH` to `user/bookings/new`
Clean up `GuestGuard` to stop redirecting to sample page
- Add a sidebar menu-item for `user/bookings/new` entitled `"New Booking"`
- Add `AdminGuard` to protect admin pages from non-admin usage

---

## Docker
```
docker compose down
docker compose up --build
docker compose exec web npx prisma migrate deploy
docker compose exec web npx prisma db seed
```
