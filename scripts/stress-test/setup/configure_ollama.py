"""
配置 Ollama 模型提供商连接到宿主机
"""
import os
import sys
import json

# 添加 api 目录到路径
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../..', 'api'))

def configure_ollama():
    """配置 Ollama 提供商使用宿主机的服务"""
    
    # Docker 网桥 IP（从 Dev Container 访问宿主机）
    ollama_host = "http://172.17.0.1:11434"
    
    print("🔧 Configuring Ollama provider...")
    print(f"   Host: {ollama_host}")
    
    # 测试连接
    import requests
    try:
        response = requests.get(f"{ollama_host}/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get('models', [])
            print(f"\n✅ Connection successful!")
            print(f"📋 Available models:")
            for model in models:
                print(f"   - {model['name']}")
            
            # 保存配置到环境变量文件
            env_file = os.path.join(os.path.dirname(__file__), '../../../api/.env')
            
            # 读取现有 .env 文件
            env_lines = []
            if os.path.exists(env_file):
                with open(env_file, 'r') as f:
                    env_lines = f.readlines()
            
            # 更新或添加 Ollama 配置
            ollama_config_found = False
            new_env_lines = []
            for line in env_lines:
                if line.startswith('OLLAMA_API_BASE_URL='):
                    new_env_lines.append(f'OLLAMA_API_BASE_URL={ollama_host}\n')
                    ollama_config_found = True
                elif line.startswith('OLLAMA_API_KEY='):
                    new_env_lines.append('OLLAMA_API_KEY=ollama\n')
                else:
                    new_env_lines.append(line)
            
            # 如果配置不存在，添加它
            if not ollama_config_found:
                new_env_lines.append('\n# Ollama Configuration\n')
                new_env_lines.append(f'OLLAMA_API_BASE_URL={ollama_host}\n')
                new_env_lines.append('OLLAMA_API_KEY=ollama\n')
            
            # 写回文件
            with open(env_file, 'w') as f:
                f.writelines(new_env_lines)
            
            print(f"\n✅ Configuration saved to {env_file}")
            print(f"\n💡 Next steps:")
            print(f"   1. Restart Dify API server:")
            print(f"      cd /workspaces/dify.git/api")
            print(f"      uv run gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app")
            print(f"   2. Open Dify Web UI: http://localhost:3000")
            print(f"   3. Go to Settings → Model Provider → Ollama")
            print(f"   4. Enter Base URL: {ollama_host}")
            print(f"   5. Save and select Ollama models in your workflows")
            
        else:
            print(f"❌ Connection failed: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Connection test failed: {e}")
        print(f"\n⚠️  Please ensure:")
        print(f"   1. Ollama is running on the host machine")
        print(f"   2. Ollama is listening on 0.0.0.0:11434 (not just 127.0.0.1)")
        print(f"   3. Run on host: export OLLAMA_HOST=0.0.0.0:11434 && ollama serve")


if __name__ == '__main__':
    configure_ollama()
