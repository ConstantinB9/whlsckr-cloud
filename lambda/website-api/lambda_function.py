from fastapi import FastAPI

from router import router
from mangum import Mangum

app = FastAPI()


app.include_router(router, prefix="/whlsckr_website/api")


lambda_handler = Mangum(app)
