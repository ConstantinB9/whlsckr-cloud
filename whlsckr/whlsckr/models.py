from typing import Optional, Dict, Any
from pydantic import BaseModel, EmailStr


class StravaPrivacySettings(BaseModel):
    """Class Representing the privacy Settings for Strava"""

    calories: bool = True
    heart_rate: bool = True
    speed: bool = True
    power: bool = True


class StravaCredentials(BaseModel):
    """Class Representing the Login Credentials for Strava"""

    email: EmailStr
    password: str


class AccessToken(BaseModel):
    """Class representing a refreshable token"""

    access_token: str
    refres_token: str
    expires_at: int


class UserDatabaseEntry(BaseModel):
    """Class representing a DatabaseEntry of a User"""
    
    UserId: str
    Email: EmailStr
    Password: str
    DropboxCursor: str = ""
    DropboxId: str = ""
    DropboxToken: Optional[AccessToken] = None
    StravaCredentials: Optional[StravaCredentials] = None
    StravaToken: Optional[AccessToken] = None
    StravaJWT: str = ""
    StravaPrivacySettings: StravaPrivacySettings = StravaPrivacySettings()

    @classmethod
    def from_db_item(cls, item: Dict[str, Any]):
        dropboxtoken = AccessToken.parse_raw(item.pop('DropboxToken')) if 'DropboxToken' in item else None
        stravatoken = AccessToken.parse_raw(item.pop('StravaToken')) if 'StravaToken' in item else None
        stravacredentials = AccessToken.parse_raw(item.pop('StravaCredentials')) if 'StravaCredentials' in item else None
        strava_cre