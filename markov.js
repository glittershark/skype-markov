var _ = require('lodash');

function getSeedPair(client, cb) {
    client.query("SELECT word1, word2 " +
                 "FROM chain_stems " +
                 "JOIN people " +
                 "  ON chain_stems.sender_id = people.id " +
                 //"  WHERE skypename = ? " +
                 "ORDER BY RANDOM() " +
                 "LIMIT 1", function(err, result) {
        if (err) return cb(err, null);
        cb(null, result.rows[0]);
    });
}

function triples(words) {
    if (words.length < 3) return;
    return _.map(words.slice(0, -2), function(word, i) {
        return [words[i], words[i+1], words[i+2]];
    });
}

function loadFromSkype(home){

}

