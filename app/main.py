from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import auth, babies, activities, caregivers, insights

# Create app
app = FastAPI(title="BabyCare API", version="1.0.0")

# CORS 
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(babies.router)
app.include_router(activities.router)
app.include_router(caregivers.router)
app.include_router(insights.router)

@app.get("/")
async def root():
    return {"message": "BabyCare API is running"}