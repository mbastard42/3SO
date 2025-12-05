{ adminBucket, backendBucket }:

let
  mkPolicy = bucket: suffix: actions: {
    name = "${bucket}${suffix}";
    value = {
      Version = "2012-10-17";
      Statement = [
        {
          Effect = "Allow";
          Action = actions;
          Resource = [ "arn:aws:s3:::${bucket}/*" ];
        }
      ];
    };
  };

  policies = [
    (mkPolicy adminBucket   "Rw" [ "s3:GetObject" "s3:PutObject" "s3:DeleteObject" ])
    (mkPolicy adminBucket   "Ro" [ "s3:GetObject" ])
    (mkPolicy backendBucket "Rw" [ "s3:GetObject" "s3:PutObject" "s3:DeleteObject" ])
  ];
in

builtins.listToAttrs policies