import uvicorn
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World!"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: str | None = None):
    return {"item_id": item_id, "q": q}

@app.get("/users/{user_name}")
def read_user(user_name: str, q: str | None = None):
    return {"user_name": user_name, "nothing": q}


'''
app = FastAPI()


@app.get("/")
def root():
    return {"hello root"}

@app.get("/world")
def world():
    return {"hello world"}
'''