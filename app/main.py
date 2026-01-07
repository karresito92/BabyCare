from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from .routers import auth, babies, activities, caregivers, insights


app = FastAPI(title="BabyCare API", version="1.0.0")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(auth.router)
app.include_router(babies.router)
app.include_router(activities.router)
app.include_router(caregivers.router)
app.include_router(insights.router)


@app.get("/health")
@app.head("/health")
async def health_check():
    """Simple health check endpoint that responds to both GET and HEAD requests"""
    return {"status": "ok", "service": "BabyCare API"}


app.mount("/", StaticFiles(directory="frontend_dist", html=True), name="static")