var faker = require("faker");
var mysql = require("mysql");
var connection = mysql.createConnection({
    multipleStatements: true,    
    host:'localhost',
    user:'vuduong191',
    database:'ig_clone'
});
// var i=1;
// function consoleb(){
//     if(i<258){
//         if(i<256){
//             console.log("---------------------------------------------------");
//         }
//         var image_url = 'https://picsum.photos/400?image='+i;
//         var q = "UPDATE photos SET image_url ='"+image_url+"' WHERE id = "+i;
//         connection.query(q, function(error, results, fields){
//             if(error) throw error;
//             console.log("shit");
//         });
//         i++;
//         consoleb();
//     }
// }
// consoleb();
for (var i=1;i<258;i++){
        var image_url = 'https://picsum.photos/400?image='+i;
        var q = "UPDATE photos SET image_url ='"+image_url+"' WHERE id = "+i;
    connection.query(q, function(error, results, fields){
        if(error) throw error;
        console.log(results);
    });
}
// var k = 1;
// function consolea(){
// if(k<101){
//     console.log("----------------------------------------");
//     k++;
//     consolea();
// }}
// consolea();
for (var k=1;k<101;k++){
    console.log("----------------------------------------");
    var randomEmail = faker.internet.email();
    var randomCity = faker.address.city();
    var q2 =  "UPDATE users SET useremail ='"+randomEmail+"', usercity ='"+randomCity+"' WHERE id = "+k;
    connection.query(q2, function(error, results, fields){
        if(error) throw error;
        console.log(k);
    });
}
connection.end();