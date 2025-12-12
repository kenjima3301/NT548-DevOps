import os
import sys
import django
import pytest
from pathlib import Path
from decimal import Decimal

# Setup Django environment
BASE_DIR = Path(__file__).parent.parent.parent.parent  # ci-cd/sonarqube/tests/ -> root
sys.path.insert(0, str(BASE_DIR / "web" / "dorashop"))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dorashop.settings')
django.setup()

from django.contrib.auth.models import User
from products.models import Comic


# ==================== FIXTURES ====================

@pytest.fixture
def client():
    """Django test client fixture"""
    from django.test import Client
    return Client()


@pytest.fixture
def sample_comic(db):
    """Fixture tạo một comic mẫu"""
    return Comic.objects.create(
        title="Test Comic",
        author="Test Author",
        price=Decimal("29.99"),
        stock=50
    )


@pytest.fixture
def sample_comics(db):
    """Fixture tạo nhiều comics mẫu"""
    comics = []
    comics.append(Comic.objects.create(
        title="One Piece Vol.1",
        author="Eiichiro Oda",
        price=Decimal("50.00"),
        stock=100
    ))
    comics.append(Comic.objects.create(
        title="Naruto Vol.1",
        author="Masashi Kishimoto",
        price=Decimal("45.00"),
        stock=75
    ))
    comics.append(Comic.objects.create(
        title="Dragon Ball Vol.1",
        author="Akira Toriyama",
        price=Decimal("40.00"),
        stock=80
    ))
    return comics


@pytest.fixture
def django_user(db):
    """Fixture tạo user Django"""
    return User.objects.create_user(
        username='testuser',
        email='testuser@example.com',
        password='testpass123'
    )


@pytest.fixture
def django_superuser(db):
    """Fixture tạo superuser Django"""
    return User.objects.create_superuser(
        username='admin',
        email='admin@example.com',
        password='adminpass123'
    )


@pytest.fixture
def comic_with_no_stock(db):
    """Fixture tạo comic hết hàng"""
    return Comic.objects.create(
        title="Out of Stock Comic",
        author="Test Author",
        price=Decimal("35.00"),
        stock=0
    )


@pytest.fixture
def expensive_comic(db):
    """Fixture tạo comic đắt tiền"""
    return Comic.objects.create(
        title="Expensive Limited Edition",
        author="Famous Author",
        price=Decimal("999.99"),
        stock=5
    )


@pytest.fixture(autouse=True)
def enable_db_access_for_all_tests(db):
    """
    Automatically enable database access for all tests
    This fixture runs for every test
    """
    pass