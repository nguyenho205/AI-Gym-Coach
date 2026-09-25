from pydantic import BaseModel, ConfigDict

class ExerciseResponse(BaseModel):
    id: str
    name: str
    short_description: str
    technique_focus: str
    category: str

    model_config = ConfigDict(from_attributes=True)
