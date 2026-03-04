import app from './app.json'
import errors from './errors.json'
import food_form from './food_form.json'
import food from './food.json'
import login from './login.json'
import profile from './profile.json'
import register from './register.json'
import settings from './settings.json'
import sidebar from './sidebar.json'

export default {
    ...app,
    ...errors,
    ...food_form,
    ...food,
    ...login,
    ...profile,
    ...register,
    ...settings,
    ...sidebar
}