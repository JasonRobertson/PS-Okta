function Convert-OktaAPIToken {
  ([pscredential]::new('apiToken',$connectionOkta.ApiToken)).GetNetworkCredential().Password
}