const frameworks = require('./controllers/frameworks')
const test = require('./controllers/test')
const Router = require('koa-router')
const router = new Router
router
    .get('/frameworks', frameworks.show)
    .get('/frameworks/:names', frameworks.show)
    .get('/frameworks/:name/:version', frameworks.show)
    .del('/frameworks/:name/:version', frameworks.destroy)
    .get('/frameworks/:name/:version/zip', frameworks.download)
    .post('/frameworks', frameworks.create)
    .get('/test',test.test)
    .post('/test/fileupload',test.fileupload)
    .post('/test/save',test.save)
    .del('/test/remove/:name/:version', test.remove)

module.exports = router