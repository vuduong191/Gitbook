var express = require('express');
var app = express();
var mysql = require('mysql');
var bodyParser = require('body-parser');


var connection = mysql.createConnection({
    multipleStatements: true,
    host:'localhost',
    user:'vuduong191',
    database:'ig_clone'
});

app.use(bodyParser.urlencoded({extended:true}));
app.use(express.static(__dirname+"/public"));
app.set('view engine','ejs');
// set the view engine to ejs
// EJS is a simple templating language that lets you generate HTML markup with plain JavaScript. 
app.listen(8080, function(){
    console.log("App listening on port 8080");
});
// what happens when a Get request is sent from homepage "/"
app.get("/", function(req,res){
    var q1 = "SELECT COUNT(*) as count FROM users;"+
            " SELECT photos.id, photos.image_url, users.username, photos.created_at, likecount, commentcount  FROM photos" +
            " LEFT JOIN (SELECT photo_id, COUNT(*) AS likecount FROM likes GROUP BY photo_id) AS liketable ON photos.id = liketable.photo_id"+
            " LEFT JOIN (SELECT photo_id, COUNT(*) AS commentcount FROM comments GROUP BY photo_id) AS commenttable ON photos.id = commenttable.photo_id"+
            " JOIN users ON photos.user_id = users.id"+
            " GROUP BY photos.id ORDER BY photos.created_at DESC;"+
            // Inactive users
            " SELECT id, tag_name FROM tags;"+
            " SELECT photos.id, tags.tag_name FROM photos LEFT JOIN photo_tags ON photos.id = photo_tags.photo_id LEFT JOIN tags ON photo_tags.tag_id = tags.id ORDER BY photos.id;"+
            " SELECT username FROM users LEFT JOIN photos ON photos.user_id=users.id WHERE photos.id IS NULL;" +
            // Photo of most like
            " SELECT username, COUNT(likes.user_id) as 'no_of_likes', likes.photo_id, photos.image_url FROM users"+
            " JOIN photos ON photos.user_id=users.id"+
            " JOIN likes ON photos.id=likes.photo_id"+
            " GROUP BY likes.photo_id ORDER BY no_of_likes DESC, photos.created_at DESC LIMIT 1;"+
            // Average posts per user
            " SELECT AVG(post) as times FROM ("+
            " SELECT username, COUNT(photos.id) as post FROM users"+
            " LEFT JOIN photos ON users.id=photos.user_id"+
            " GROUP BY users.username) as t;"+
            // Most common tags
            " SELECT tag_id, tag_name, COUNT(*) AS 'times' FROM photo_tags"+
            " JOIN tags ON photo_tags.tag_id=tags.id"+
            " GROUP BY tag_id ORDER BY times DESC LIMIT 3;"+
            " SELECT username FROM users ORDER BY id ASC;"
            ;
    connection.query(q1, function(error,results){
        if (error) throw error;
        var count = results[0][0].count;
        var imglistoriginal = results[1];
        var imglist=imglistoriginal.slice(0,30);
        var tagslist = results[2];
        var inactive = results[4];
        var photomostlike = results[5][0];
        var times = results[6][0];
        var users = results[8];
        var commonTags = results[7];
        var photoTags = [];
        for (var i=0;i<results[3].length;i++){
            if(photoTags[results[3][i].id-1]){ photoTags[results[3][i].id-1].push("#"+results[3][i].tag_name)}
            else {photoTags[results[3][i].id-1] = [" "];photoTags[results[3][i].id-1].push("#"+results[3][i].tag_name)}
        };
        console.log(users[0])
        
    //  res.render() will look in a views folder for the view
        res.render("home", {
            data:count,
            imglist: imglist,
            tagslist: tagslist,
            photoTags: photoTags,
            currentId: imglistoriginal.length,
            inactive: inactive,
            photomostlike: photomostlike,
            times: times,
            commonTags: commonTags,
            users: users,
        });

    });
});

// when the submit button is hit, the form triggers "/register" with method = "POST"
app.post("/register", function(req, res){
    var photo = {
        image_url : req.body.input_imgurl,
        user_id: req.body.user_idinput,
    };
    // var comment_text = "vlarua vlasea dkeia";
    var photo_id = parseInt(req.body.current_photoid,10)+1;
    var user_id_comment = req.body.input_comments;
    var user_id_likes = req.body.input_likes;
    var tag_id = req.body.input_tags;
    var q = "INSERT INTO photos SET ?";
    connection.query(q, photo, function(error, results, fields){
        if(error) {console.log(error); console.log("photos")}
    });
    var q2 = "INSERT INTO comments SET ?";
    for (var i=0;i<user_id_comment.length;i++){
        var comments = {
                comment_text: "vlarua vlasea dkeia",
                photo_id: photo_id,
                user_id: user_id_comment[i]
        };
        connection.query(q2, comments, function(error, results, fields){
            if(error){console.log(error); console.log("comments")}
        });              
    
    };
    var q3 = "INSERT INTO likes SET ?";
    for (var i=0;i<user_id_likes.length;i++){
        var likes = {
            user_id: user_id_likes[i],
            photo_id: photo_id,
        };
        connection.query(q3, likes, function(error, results, fields){
            if(error) {console.log(error); console.log("likes")}
        }); 
    };
    var q4 = "INSERT INTO photo_tags SET ?";
    for (var i=0;i<user_id_likes.length;i++){
        var tags = {
            photo_id: photo_id,
            tag_id: tag_id[i]
        };
        connection.query(q4, tags, function(error, results, fields){
            if(error){console.log(error); console.log("tags")}
        }); 
    };    
    res.redirect("/");     
    // var q2 = "INSERT INTO photos SET ?";
    // connection.query(q, photo, function(error, results, fields){
    //     if(error) throw error;
    //     res.redirect("/");
    // });
    // var q = "INSERT INTO photos SET ?";
    // connection.query(q, photo, function(error, results, fields){
    //     if(error) throw error;
    //     res.redirect("/");
    // });
    // var q = "INSERT INTO photos SET ?";
    // connection.query(q, photo, function(error, results, fields){
    //     if(error) throw error;
    //     res.redirect("/");
    // });    
    
});
