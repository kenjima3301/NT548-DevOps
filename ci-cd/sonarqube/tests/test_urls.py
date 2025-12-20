"""Test cases cho URL routing"""
import pytest
from django.urls import reverse, resolve
from products import views


class TestURLPatterns:
    """Test suite cho URL patterns"""

    def test_comic_list_url(self):
        """Test URL cho comic_list"""
        url = reverse('comic_list')
        assert url == '/test-home/'
        assert resolve(url).func == views.comic_list

    def test_home_url(self):
        """Test URL cho home"""
        url = reverse('home')
        assert url == '/'
        assert resolve(url).func == views.home

    def test_product_list_url(self):
        """Test URL cho product_list"""
        url = reverse('product_list')
        assert url == '/products/'
        assert resolve(url).func == views.product_list

    def test_product_detail_url(self):
        """Test URL cho product_detail với pk"""
        url = reverse('product_detail', kwargs={'pk': 1})
        assert url == '/products/1/'
        assert resolve(url).func == views.product_detail

    def test_product_detail_url_different_pk(self):
        """Test URL cho product_detail với pk khác nhau"""
        url_10 = reverse('product_detail', kwargs={'pk': 10})
        assert url_10 == '/products/10/'
        
        url_999 = reverse('product_detail', kwargs={'pk': 999})
        assert url_999 == '/products/999/'

    def test_cart_summary_url(self):
        """Test URL cho cart_summary"""
        url = reverse('cart:summary')
        assert url == '/cart/'
        assert resolve(url).func == views.cart_summary

    def test_login_url(self):
        """Test URL cho login"""
        url = reverse('login')
        assert url == '/login/'
        assert resolve(url).func == views.login_view

    def test_register_url(self):
        """Test URL cho register"""
        url = reverse('register')
        assert url == '/register/'
        assert resolve(url).func == views.register_view

    def test_logout_url(self):
        """Test URL cho logout"""
        url = reverse('logout')
        assert url == '/logout/'
        assert resolve(url).func == views.logout_view


class TestURLResolving:
    """Test suite cho URL resolving"""

    def test_resolve_root_url(self):
        """Test resolve URL gốc"""
        resolver = resolve('/')
        assert resolver.view_name == 'home'
        assert resolver.func == views.home

    def test_resolve_products_url(self):
        """Test resolve /products/"""
        resolver = resolve('/products/')
        assert resolver.view_name == 'product_list'

    def test_resolve_product_detail_url(self):
        """Test resolve /products/<pk>/"""
        resolver = resolve('/products/5/')
        assert resolver.view_name == 'product_detail'
        assert resolver.kwargs == {'pk': 5}

    def test_resolve_cart_url(self):
        """Test resolve /cart/"""
        resolver = resolve('/cart/')
        assert resolver.view_name == 'cart_summary'

    def test_resolve_auth_urls(self):
        """Test resolve các auth URLs"""
        login_resolver = resolve('/login/')
        assert login_resolver.view_name == 'login'
        
        register_resolver = resolve('/register/')
        assert register_resolver.view_name == 'register'
        
        logout_resolver = resolve('/logout/')
        assert logout_resolver.view_name == 'logout'


class TestURLNamespaces:
    """Test URL names và reverse"""

    def test_all_url_names_exist(self):
        """Test tất cả URL names đều có thể reverse"""
        url_names = [
            'comic_list',
            'home',
            'product_list',
            'cart_summary',
            'login',
            'register',
            'logout'
        ]
        
        for name in url_names:
            url = reverse(name)
            assert url is not None
            assert len(url) > 0

    def test_product_detail_requires_pk(self):
        """Test product_detail URL requires pk parameter"""
        with pytest.raises(Exception):
            reverse('product_detail')  # Should fail without pk

    def test_product_detail_with_pk(self):
        """Test product_detail URL with pk parameter"""
        url = reverse('product_detail', kwargs={'pk': 42})
        assert '/products/42/' == url
