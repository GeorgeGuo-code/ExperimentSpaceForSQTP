/*依赖：
express bcryptjs pg dotenv jsonwebtoken cors

npm install express bcryptjs pg dotenv jsonwebtoken
*/

const express = require('express');
const cors = require('cors');  // 引入 cors 中间件
const usersRouter = require('./routes/usersRouter');
const protectedRouter = require('./routes/protectedRouter');  // 受jwt保护的api

const app = express();

// 使用 CORS 中间件
app.use(cors({
  origin: '*',  // 或者指定允许的源，比如 'http://localhost:3000'
  methods: ['GET', 'POST', 'PUT', 'DELETE'],  // 允许的 HTTP 方法
  allowedHeaders: ['Content-Type', 'Authorization'],  // 允许的请求头
}));
app.use(express.json());  // 用于解析 JSON 格式的请求体
app.use(usersRouter);

app.use(protectedRouter);



app.listen(3000, () => {
  console.log('Server listen on port 3000');
})