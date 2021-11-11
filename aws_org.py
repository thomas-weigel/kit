#!/usr/bin/env python3

from collections import namedtuple
from dataclasses import dataclass
import sys

try:
    import boto3
except ModuleNotFoundError:
    print("Required Module: boto3\nModule not installed for python3.", file=sys.stde)
    sys.exit(1)


def main():
    org = Organization()
    print(f"AWS Organization under Account ID {org.master}")
    for root in org.roots:
        root.display()


class Organization:
    """
    An interface to the AWS Organization at the top level.
    """

    def __init__(self, client=None):
        if client is None:
            self._client = boto3.client("organizations")
        else:
            self._client = client

    @property
    def master(self):
        """The ID for the master account for the AWS Organization."""
        return self._client.describe_organization()['Organization']['MasterAccountId']

    @property
    def roots(self):
        """
        A root is a top-level parent node in AWS Organizations. Despite the name, you can have
        multiple roots. Each root will have all of the same accounts, just organized different
        ways. Unless you have a good reason, however, you should only have one root.
        """

        for root in self._client.list_roots()['Roots']:
            name = root['Id']
            yield OrgContainer(container_id=name, name=name, client=self._client)


class OrgContainer:
    """
    In AWS Organizations, a "container" is any Root or OU: either can contain one or more OUs or
    Accounts.

    Although there are some differences between a Root and OU (Roots are always at the top of the
    hierarchy, whereas OUs are always in the middle, for example), for code purposes they are
    functionally identical.
    """

    def __init__(self, container_id:str, name:str, client=None):
        self.id = container_id
        self.name = name
        if client is None:
            self._client = boto3.client("organizations")
        else:
            self._client = client

    @property
    def units(self):
        results = self._client.list_organizational_units_for_parent(ParentId=self.id)['OrganizationalUnits']
        for ou in results:
            yield OrgContainer(container_id=ou['Id'], name=ou['Name'], client=self._client)

    @property
    def accounts(self):
        results = self._client.list_children(ParentId=self.id, ChildType='ACCOUNT')['Children']
        for account in results:
            account_id = account['Id']
            description = self._client.describe_account(AccountId=account_id)['Account']
            name = description['Name']
            email = description['Email']
            yield OrgAccount(name, account_id, email)

    def display(self, depth:int=0):
        spacer = ' ' * depth * 2

        print(f"{spacer}{self.name} -- {self.id}")

        accounts = list(self.accounts)
        for account in accounts:
            print(f"  {spacer}{account.name} ({account.id} -- {account.email})")
        if len(accounts):
            print("")

        units = list(self.units)
        for unit in units:
            unit.display(depth=depth+1)


@dataclass(order=True, frozen=True)
class OrgAccount:
    name:str
    id:str
    email:str


if __name__=='__main__':
    main()
