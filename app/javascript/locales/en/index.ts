import app from './app.json'
import errors from './errors.json'
import food_form from './food_form.json'
import food from './food.json'
import login from './login.json'
import profile from './profile.json'
import register from './register.json'
import settings from './settings.json'
import sidebar from './sidebar.json'
import finance from './finance.json'
import finance_form from './finance_form.json'
import forgot_password from './forgot_password.json'
import reset_password from './reset_password.json'

export default {
  ...app,
  ...errors,
  ...finance,
  ...finance_form,
  ...food_form,
  ...food,
  ...forgot_password,
  ...login,
  ...profile,
  ...register,
  ...reset_password,
  ...settings,
  ...sidebar,
}
