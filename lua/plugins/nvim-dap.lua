local env_file = vim.fn.getcwd() .. "/.env"
local ini_file = vim.fn.getcwd() .. "/settings.ini"
local project_config = {}

-- Функция для чтения .env
local function load_env(file)
  local f = io.open(file, "r")
  if f then
    for line in f:lines() do
      local key, value = line:match "([^=]+)=(.+)"
      if key and value then project_config[key] = value end
    end
    f:close()
  end
end

-- Функция для чтения settings.ini
local function load_ini(file)
  local f = io.open(file, "r")
  if f then
    for line in f:lines() do
      local key, value = line:match "([^=]+)=(.+)"
      if key and value then
        project_config[key] = value:gsub("^%s*(.-)%s*$", "%1") -- Убираем лишние пробелы
      end
    end
    f:close()
  end
end

-- Загружаем .env или settings.ini, если .env нет
if vim.fn.filereadable(env_file) == 1 then
  load_env(env_file)
elseif vim.fn.filereadable(ini_file) == 1 then
  load_ini(ini_file)
end

return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"

      dap.adapters.python = {
        type = "executable",
        command = vim.fn.exepath "python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            local python_path = project_config.PYTHON_VENV or vim.fn.exepath "python"
            if not python_path:match "^/" then python_path = vim.fn.expand(vim.fn.getcwd() .. "/" .. python_path) end
            return python_path
          end,
          cwd = project_config.SOURCE_ROOT or vim.fn.getcwd(),
          env = {
            PYTHONPATH = project_config.SOURCE_ROOT or vim.fn.getcwd(),
          },
          justMyCode = false,
        },
        {
          type = "python",
          request = "launch",
          name = "Django Runserver",
          program = "${workspaceFolder}/manage.py",
          args = { "runserver", "--noreload" },
          pythonPath = function()
            local python_path = project_config.PYTHON_VENV or vim.fn.exepath "python"
            if not python_path:match "^/" then python_path = vim.fn.expand(vim.fn.getcwd() .. "/" .. python_path) end
            return python_path
          end,
          cwd = project_config.SOURCE_ROOT or vim.fn.getcwd(),
          env = {
            PYTHONPATH = project_config.SOURCE_ROOT or vim.fn.getcwd(),
          },
          justMyCode = false,
          django = true,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch file with arguments",
          program = "${file}",
          args = function()
            local input = vim.fn.input "Arguments: "
            return vim.fn.split(input, " ", true)
          end,
          pythonPath = function()
            local python_path = project_config.PYTHON_VENV or vim.fn.exepath "python"
            if not python_path:match "^/" then python_path = vim.fn.expand(vim.fn.getcwd() .. "/" .. python_path) end
            return python_path
          end,
          cwd = project_config.SOURCE_ROOT or vim.fn.getcwd(),
          env = {
            PYTHONPATH = project_config.SOURCE_ROOT or vim.fn.getcwd(),
          },
          justMyCode = false,
        },
      }
    end,
  },
}
