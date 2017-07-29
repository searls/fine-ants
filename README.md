# fine_ants 🐜

Got finance problems? Have some fine_ants to help.

## Usage

```
$ gem install fine_ants
```

And then:

``` ruby
accounts = FineAnts.download(:vanguard, {
  :user => "janelastname",
  :password => ENV['VANGUARD_PASSWORD']
})

puts accounts
#=> [{
#      :adapter => :vanguard,
#      :user => "janelastname",
#      :id => "234567890",
#      :amount => BigDecimal.new("1234.56")
# }]
```

## What?

[I](https://twitter.com/searls) wrote this, because
[nearly](https://www.mint.com)
[every](https://www.personalcapital.com/financial-software)
[service](https://www.youneedabudget.com)
[and](https://www.iggsoftware.com/banktivity/)
[app](http://moneywizapp.com/mac/)
that
offers multi-institution financial dashboarding stores your passwords in a way
that can be decrypted by the service (by design, since they need your credentials
to scrape the banks' sites). This means if these rando services get hacked, the
passwords to _all of your financial accounts_ can be compromised at once.

The FDIC and SIPC are pretty great protections from the dissolution of banks, but
it doesn't protect you from their web sites being compromised, much less the web
sites of services that scrape them just to give you a pretty dashboard.

Handing all your financial credentials to anyone seems foolish, so I started the
fine_ants gem to build adapters for the various financial institutions I use. It
uses [capybara](https://github.com/jnicklas/capybara) to automate a browser and
scrape your account totals from your bank's webapp. It even supports
[2FA](https://en.wikipedia.org/wiki/Multi-factor_authentication). Since it's
designed to be run locally, it simply uses `gets` to read SMS, e-mail, and TOTP
tokens from
[stdin](https://en.wikipedia.org/wiki/Standard_streams#Standard_input_.28stdin.29)
when a login process requires a 2FA challenge.

# Adapters

Right now, FineAnts ships with adapters for:

| Name                                                                                    | Adapter Name      |
| --------------------------------------------------------------------------------------- | ----------------- |
| [Vanguard Personal Investment](https://personal.vanguard.com/us/hnwnesc/nesc/LoginPage) | `:vanguard` |
| [PNC Personal Banking](https://www.pnc.com/en/personal-banking.html) | `:pnc` |
| [Betterment](https://www.betterment.com) | `:betterment` |
| [E*Trade](https://www.etrade.com) | `:etrade` |
| [Chase](https://www.chase.com) | `:chase` |
| [Simple (BBVA)](https://www.simple.com) | `:simple` |
| [Simple (Bancorp)](https://www.simple.com) | `:simple_bancorp` |
| [Target REDcard](https://rcam.target.com) | `:target` |
| [Purdue Federal Credit Union](https://www.purduefed.com) | `:purduefed` |
| [Ohio State Teacher Retirement System (STRS)](https://www.nrsstrsoh.org) | `:strs` |
| [Zillow (Zestimate, user is the "zpid")](https://zillow.com) | `:zillow` |

You can also implement your own adapter and pass it to `FineAnts.download`. The
expected public contract of an adapter is:

``` ruby
require "bigdecimal"

class MyAdapter
  def initialize(credentials)
    # `credentials` should be a hash with (at least) :user and :password entries.
  end

  def login
    # Login to the system
    # return true if login is successful
    # return false if a 2FA response is needed (see #two_factor_response)
    # if credentials fail, then raise FineAnts::LoginFailedError.new
  end

  def two_factor_response(answer)
    # This method is optional and useful if the service supports 2FA
    # If defined, the user will be prompted (via `gets`) to type in a 2FA
    # challenge response, which will be passed here. With the answer in hand,
    # automate entering the 2FA token and submitting.
  end

  def download
    # Download all the user's accounts and total values.
    # FineAnts expects this method to return data shaped like:
    [
      {
        :adapter => :your_adapter_name,
        :user => "theloginbeingused",
        :id => "id-of-the-account",
        :amount => BigDecimal.new("1234.56")
      }
    ]
  end
end
```

You can pass your own adapter class:

``` ruby
accounts = FineAnts.download(MyAdapter, {
  :user => "randojones",
  :password => ENV['MY_PASSWORD']
})
```

