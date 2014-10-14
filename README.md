Lemonade is a simple, daemonized process for uploading your popular Instagram photos 
to Flickr. Popular = 'more than three likes.' 

##Usage
`$bundle exec ruby photo_daemon.rb start`

`tail log/poster.log -f` to view output

##Features
1. Runs as a background process.
2. Caches photos you've already uploaded in Redis so you avoid the
oh-so-awkward moment of uploading the same file twice. 
3. I'm thinking...

##Issues
1. This is a demonstration only, polling one user. In a robust application, I'd cache or hit an endpoint to fetch the user-ids and access-tokens of all the users who had oauthed my Flickr and Instagram apps. 
2. You need to supply your own oauth-tokens for Flickr and IG. See below.
3. No work has been put into monitoring for Instagram's heavy-handed api limits.


###Getting Redis to work, OSX
It's a little funky, which is why it's useful to run under something like Vagrant.
If not, 
`$brew install vagrant`
Then `$redis-server` in a second terminal window. OR make sure it launches at boot: 
http://naleid.com/blog/2011/03/05/running-redis-as-a-user-daemon-on-osx-with-launchd/

###Getting a Flickr Auth Token
Follow the awesome suggestions made here by 
http://blog.idifysolutions.com/2014/07/save-images-to-flickr-using-flickraw-gem/
Warning: it's very Rails-heavy.

###Getting an Instagram Auth Token
There's no way around this, you'll need to register an app with Instagram so you can get a client ID and a client secret. 

Once you do that, you can go through the pain of writing the front-end oauth route, or do this! You'll need to remember client-id, client-secret, and redirect-uri from above.

1. Use the following address:
GET the following:
https://api.instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=code
It will respond with a code. Write that down. 

2. Once you have the code param from above, enter the following cURL:
```
curl -F 'client_id=CLIENT-ID' -F 'client_secret=CLIENT-SECRET' -F 'grant_type=authorization_code' -F 'redirect_uri=REDIRECT-URI' -F 'code=CODE' -F 'aspect=media' https://api.instagram.com/oauth/access_token
```
3. Your cURL will return JSON like this:
```
{"access_token":"ACCESS-TOKEN","user":{"username":"gxrobillard","bio":"Humorist. Open Sourcerer. Mad Soccer Dad. Some assembly required.","website":"http:\/\/alldaycoffee.net","profile_picture":"http:\/\/images.ak.instagram.com\/profiles\/profile_31741931_75sq_1334701202.jpg","full_name":"G. Xavier Robillard","id":"31741931"}}
```
####ToDo
Implement a better method to manage env variables. Thinking a rake task?