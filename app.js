var app = require('express')(),
    exec = require('child_process').exec;

app.get('/', function(req, res) {
    exec('python2 ./markov.py', function(err, stdout, stderr) {
        if (err || stderr) {
            res.render('error.jade', { error: err, stdout: stdout, stderr: stderr });
            return;
        }

        res.render('markov.jade', { sentence: stdout });
    });
});

app.listen(process.env.PORT || 8000);
