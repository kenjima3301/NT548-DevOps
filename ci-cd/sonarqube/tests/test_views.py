"""Test cases cho views của products app"""
import pytest
from django.urls import reverse
from django.test import Client
from decimal import Decimal
from products.models import Comic
from django.contrib.auth.models import User


@pytest.mark.django_db
class TestComicListView:
    """Test suite cho comic_list view"""

    def test_comic_list_view_status_code(self, client):
        """Test comic_list view trả về status 200"""
        response = client.get(reverse('comic_list'))
        assert response.status_code == 200

    def test_comic_list_view_template(self, client):
        """Test comic_list view sử dụng đúng template"""
        response = client.get(reverse('comic_list'))
        assert 'products/comic_list.html' in [t.name for t in response.templates]

    def test_comic_list_view_context(self, client, sample_comics):
        """Test comic_list view có comics trong context"""
        response = client.get(reverse('comic_list'))
        assert 'comics' in response.context
        assert len(response.context['comics']) == 3


@pytest.mark.django_db
class TestHomeView:
    """Test suite cho home view"""

    def test_home_view_status_code(self, client):
        """Test home view trả về status 200"""
        response = client.get(reverse('home'))
        assert response.status_code == 200

    def test_home_view_template(self, client):
        """Test home view sử dụng đúng template"""
        response = client.get(reverse('home'))
        assert 'home.html' in [t.name for t in response.templates]

    def test_home_view_featured_comics(self, client, sample_comics):
        """Test home view hiển thị featured comics"""
        response = client.get(reverse('home'))
        assert 'featured_comics' in response.context
        # Home view lấy 8 comics đầu tiên
        assert len(response.context['featured_comics']) <= 8

    def test_home_view_with_many_comics(self, client):
        """Test home view chỉ hiển thị tối đa 8 comics"""
        # Tạo 10 comics
        for i in range(10):
            Comic.objects.create(
                title=f"Comic {i}",
                author=f"Author {i}",
                price=Decimal("10.00"),
                stock=10
            )
        
        response = client.get(reverse('home'))
        assert len(response.context['featured_comics']) == 8


@pytest.mark.django_db
class TestProductListView:
    """Test suite cho product_list view"""

    def test_product_list_view_status_code(self, client):
        """Test product_list view trả về status 200"""
        response = client.get(reverse('product_list'))
        assert response.status_code == 200

    def test_product_list_view_template(self, client):
        """Test product_list view sử dụng đúng template"""
        response = client.get(reverse('product_list'))
        assert 'products/list.html' in [t.name for t in response.templates]

    def test_product_list_view_all_comics(self, client, sample_comics):
        """Test product_list view hiển thị tất cả comics"""
        response = client.get(reverse('product_list'))
        assert 'comics' in response.context
        assert len(response.context['comics']) == 3


@pytest.mark.django_db
class TestProductDetailView:
    """Test suite cho product_detail view"""

    def test_product_detail_view_status_code(self, client, sample_comic):
        """Test product_detail view trả về status 200"""
        response = client.get(reverse('product_detail', kwargs={'pk': sample_comic.pk}))
        assert response.status_code == 200

    def test_product_detail_view_template(self, client, sample_comic):
        """Test product_detail view sử dụng đúng template"""
        response = client.get(reverse('product_detail', kwargs={'pk': sample_comic.pk}))
        assert 'products/detail.html' in [t.name for t in response.templates]

    def test_product_detail_view_context(self, client, sample_comic):
        """Test product_detail view có comic đúng trong context"""
        response = client.get(reverse('product_detail', kwargs={'pk': sample_comic.pk}))
        assert 'comic' in response.context
        assert response.context['comic'].pk == sample_comic.pk
        assert response.context['comic'].title == sample_comic.title

    def test_product_detail_view_not_found(self, client):
        """Test product_detail view với pk không tồn tại trả về 404"""
        response = client.get(reverse('product_detail', kwargs={'pk': 9999}))
        assert response.status_code == 404


@pytest.mark.django_db
class TestCartSummaryView:
    """Test suite cho cart_summary view"""

    def test_cart_summary_view_status_code(self, client):
        """Test cart_summary view trả về status 200"""
        response = client.get(reverse('cart:summary'))
        assert response.status_code == 200

    def test_cart_summary_view_template(self, client):
        """Test cart_summary view sử dụng đúng template"""
        response = client.get(reverse('cart:summary'))
        assert 'cart/summary.html' in [t.name for t in response.templates]


@pytest.mark.django_db
class TestAuthViews:
    """Test suite cho authentication views"""

    def test_login_view_status_code(self, client):
        """Test login view trả về status 200"""
        response = client.get(reverse('login'))
        assert response.status_code == 200

    def test_login_view_template(self, client):
        """Test login view sử dụng đúng template"""
        response = client.get(reverse('login'))
        assert 'auth/login.html' in [t.name for t in response.templates]

    def test_register_view_status_code(self, client):
        """Test register view trả về status 200"""
        response = client.get(reverse('register'))
        assert response.status_code == 200

    def test_register_view_template(self, client):
        """Test register view sử dụng đúng template"""
        response = client.get(reverse('register'))
        assert 'auth/register.html' in [t.name for t in response.templates]

    def test_logout_view_redirect(self, client, django_user):
        """Test logout view redirect về home"""
        client.force_login(django_user)
        response = client.get(reverse('logout'))
        assert response.status_code == 302
        assert response.url == reverse('home')

    def test_logout_view_without_login(self, client):
        """Test logout view khi chưa đăng nhập"""
        response = client.get(reverse('logout'))
        assert response.status_code == 302


@pytest.mark.django_db
class TestViewsIntegration:
    """Test tích hợp các views"""

    def test_navigation_flow(self, client, sample_comic):
        """Test flow điều hướng từ home -> product_list -> product_detail"""
        # Truy cập home
        response = client.get(reverse('home'))
        assert response.status_code == 200
        
        # Truy cập product_list
        response = client.get(reverse('product_list'))
        assert response.status_code == 200
        
        # Truy cập product_detail
        response = client.get(reverse('product_detail', kwargs={'pk': sample_comic.pk}))
        assert response.status_code == 200

    def test_empty_database_views(self, client):
        """Test các views khi database trống"""
        response_home = client.get(reverse('home'))
        assert response_home.status_code == 200
        
        response_list = client.get(reverse('product_list'))
        assert response_list.status_code == 200
        
        response_comic_list = client.get(reverse('comic_list'))
        assert response_comic_list.status_code == 200
