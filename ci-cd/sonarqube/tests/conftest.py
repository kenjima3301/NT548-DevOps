import os
import sys
import django
from pathlib import Path

# Setup Django environment
BASE_DIR = Path(__file__).parent.parent.parent.parent  # ci-cd/sonarqube/tests/ -> root
sys.path.insert(0, str(BASE_DIR / "web" / "dorashop"))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dorashop.settings')
django.setup()