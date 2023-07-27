const Koa = require('koa')
const router = require('./server/routes')
const logger = require('koa-logger')
const mongoose = require('mongoose')
const koaBody = require('koa-body')

const app = new Koa

const demo = require('./demo')


mongoose.connect('mongodb://localhost/binary_database')


app.use(koaBody({ multipart: true }))
app.use(logger())

// koa支持跨域请求 （跨域请求被拦截问题——has been blocked by CORS policy: No ‘Access-Control-Allow-Origin‘ header is present on...必须要在路由之前配置）
app.use(async (ctx, next) => {
    ctx.set('Access-Control-Allow-Origin', '*')
    ctx.set('Access-Control-Allow-Headers', 'content-type')
    ctx.set('Access-Control-Allow-Methods', 'OPTIONS,GET,PUT,POST,DELETE')
    await next()
    // 允许所有跨域
    if (ctx.request.method === 'OPTIONS') {
        console.log('跨域请求')
        ctx.response.status = 200
        ctx.response.message = 'OK'
    }
})

app.use(router.routes())

var r = app.listen(8888)

console.log(r)