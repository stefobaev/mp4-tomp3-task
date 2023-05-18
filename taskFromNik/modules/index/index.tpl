<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>File Upload Demo</title>
        <script src="https://sdk.amazonaws.com/js/aws-sdk-2.945.0.min.js"></script>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script>
            // Initialize the Amazon Cognito credentials provider
            AWS.config.region = '${region}'; // Region
            AWS.config.credentials = new AWS.CognitoIdentityCredentials({
                IdentityPoolId: '${identity_pool_id}',
            });
            // Redirect to Cognito login page
            function redirectToLogin() {
                var clientId = '${clientId}';
                var redirectUri = 'https://domain.com';
                var loginUrl = "https://domain.auth.${region}.amazoncognito.com/login?client_id=${clientId}&response_type=code&scope=email+openid+phone&redirect_uri=https%3A%2F%2Fdomain.com";
                window.location.href = loginUrl;
            }
         
            // Get the authentication code from the URL parameters
            function getAuthCode() {
                var searchParams = new URLSearchParams(window.location.search);
                return searchParams.get('code');
            }
         
            // Get the temporary credentials for the authenticated user
            function getCredentials(authCode) {
                var clientId = '${clientId}';
                var redirectUri = 'https://domain.com';
                var authEndpoint = 'https://domian.auth.${region}.amazoncognito.com/oauth2/token';
            
                var params = {
                    grant_type: 'authorization_code',
                    client_id: clientId,
                    code: authCode,
                    redirect_uri: redirectUri,
                };
         
                return fetch(authEndpoint, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: new URLSearchParams(params)
                })
                .then(response => response.json())
                .then(data => {
                    var idToken = data.id_token;
                    var accessToken = data.access_token;
                    var refreshToken = data.refresh_token;
                    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
                        IdentityPoolId: '${identity_pool_id}',
                        Logins: {
                            'cognito-idp.${region}.amazonaws.com/${userPoolId}': idToken
                        }
                    });
                    AWS.config.credentials.refresh(() => {
                console.log(AWS.config.credentials);
                        // The temporary credentials are now available
                        alert('Authenticated successfully');
                        // Show the file upload controls and hide the login button
                        $('#upload-container').show();
                        $('#login-container').hide();
                        // Show the logout button
                        $('#logout-btn').show();
                    });
                })
                .catch(error => alert(error.message));
            }
            // Log out the authenticated user
            function logout() {
            AWS.config.credentials = null;
            localStorage.clear();
            window.location.href = "https://domain.auth.${region}.amazoncognito.com/logout?client_id=${clientId}&logout_uri=https%3A%2F%2Fdomain.com";
            }
         
            $(document).ready(function() {
            // Hide the file upload controls and logout button
            $('#upload-container, #logout-btn').hide();
            
            // Check for an authentication code in the URL parameters
            var authCode = getAuthCode();
            if (authCode) {
            getCredentials(authCode);
            } else {
            var cachedCredentials = localStorage.getItem('awsCredentials');
            if (cachedCredentials) {
                AWS.config.credentials = new AWS.CognitoIdentityCredentials(JSON.parse(cachedCredentials));
                AWS.config.credentials.refresh(() => {
                    // The temporary credentials are now available
                    $('#upload-container, #logout-btn').show();
                });
            }
            }
            });
         
            // Upload a file to the S3 bucket
            function uploadFile() {
            var s3 = new AWS.S3();
            var file = document.getElementById('file').files[0];
            var fileName = file.name;
            var bucketName = '${bucketName}';
            var folderName = 'uploaded';
            var key = folderName + '/' + fileName;
            // Get the email address of the authenticated user from the Cognito identity token
            var idToken = AWS.config.credentials.params.Logins['cognito-idp.${region}.amazonaws.com/${userPoolId}'];
            var email = JSON.parse(atob(idToken.split('.')[1])).email;
            // Refresh the temporary credentials
            AWS.config.credentials.refresh((error) => {
            if (error) {
                alert('Error refreshing credentials: ' + error);
                return;
            }
            // The temporary credentials are now available
            var params = {
                Bucket: bucketName,
                Key: key,
                Body: file,
                Metadata: {
                    'email': email
                }
            };
            s3.upload(params, function (err, data) {
                if (err) {
                    alert('Error uploading file: ' + err.message);
                } else {
                    alert('File uploaded successfully');
                }
            });
            });
            }
         
        </script>
    </head>
    <body>
        <h1>File Upload Demo</h1>
        <div id="login-container">
            <h2>Please log in to upload a file</h2>
            <button id="login-btn" onclick="redirectToLogin()">Log In</button>
        </div>
        <div id="upload-container" style="display:none;">
            <input type="file" id="file" accept="video/*">
            <button id="upload-btn" onclick="uploadFile()">Upload</button>
        </div>
        <button id="logout-btn" onclick="logout()">Log Out</button>
    </body>
</html>
