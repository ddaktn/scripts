
### Get a list of all users and their password expiration date ###
get-aduser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties "DisplayName","msDS-UserPasswordExpiryTimeComputed" | 
select -Property "Displyname",@{N="ExpiryDate";E={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}


### Find a single user's password expiration date ###
get-aduser mss92473 -Properties "DisplayName","msDS-UserPasswordExpiryTimeComputed" | 
select -Property "Displyname",@{N="ExpiryDate";E={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}