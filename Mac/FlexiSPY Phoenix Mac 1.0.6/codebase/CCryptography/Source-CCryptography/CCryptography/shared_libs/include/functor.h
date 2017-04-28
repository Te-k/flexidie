     

#ifndef _CFUNCTOR_H
#define _CFUNCTOR_H

/* Functor used to run the thread
*/

namespace Thread
{

	class cFunctor
        {
        public:
            /**
             * Constructor
             *
             */
            cFunctor ( void )
            {
                /* FunctorObjectHandler::getInstance( )->addFunctor( this ); */
            }

            /**
             * Destructor
             *
             */
            virtual ~cFunctor ( void )
            {
                /* FunctorObjectHandler::getInstance( )->removeFunctor( this ); */
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void ) = 0;
        };


        template <typename CLASS>
        class Functor0 : public cFunctor
        {
        private:
            typedef void (CLASS::*METHOD) ( void );
            CLASS*  m_object;
            METHOD  m_method;

        public:
            /**
             * Constructor
             *
             */
            Functor0 ( METHOD m, CLASS *o )
            {
                m_object = o;
                m_method = m;
            }

            /**
             * Copy constructor
             *
             */
            Functor0 ( const Functor0 &f )
            {
                m_object = f.m_object;
                m_method = f.m_method;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                (m_object->*m_method)( );
            }
        };

        template <typename CLASS, typename T0>
        class Functor1 : public cFunctor
        {
        private:
            typedef void (CLASS::*METHOD) ( T0 );
            CLASS*  m_object;
            METHOD  m_method;
            T0      m_param0;

        public:
            /**
             * Constructor
             *
             */
            Functor1 ( METHOD m, 
                       CLASS *o, 
                       T0 p0 )
            : m_param0( p0 )
            {
                m_object = o;
                m_method = m;
            }

            /**
             * Copy constructor
             *
             */
            Functor1 ( const Functor1 &f )
            : m_param0( f.m_param0 )
            {
                m_object = f.m_object;
                m_method = f.m_method;

            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                (m_object->*m_method)( m_param0 );
            }
        };

        template <typename CLASS, typename T0, typename T1>
        class Functor2 : public cFunctor
        {
        private:
            typedef void (CLASS::*METHOD) ( T0, T1 );
            CLASS*  m_object;
            METHOD  m_method;
            T0      m_param0;
            T1      m_param1;

        public:
            /**
             * Constructor
             *
             */
            Functor2 ( METHOD m, 
                       CLASS *o, 
                       T0 p0, 
                       T1 p1 )
            : m_param0( p0 ), 
              m_param1( p1 )
            {
                m_object = o;
                m_method = m;
            }

            /**
             * Copy constructor
             *
             */
            Functor2 ( const Functor2 &f )
            : m_param0( f.m_param0 ), 
              m_param1( f.m_param1 )
            {
                m_object = f.m_object;
                m_method = f.m_method;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                (m_object->*m_method)( m_param0, m_param1 );
            }
        };

        template <typename CLASS, typename T0, typename T1, typename T2>
        class Functor3 : public cFunctor
        {
        private:
            typedef void (CLASS::*METHOD) ( T0, T1, T2 );
            CLASS*  m_object;
            METHOD  m_method;
            T0      m_param0;
            T1      m_param1;
            T2      m_param2;

        public:
            /**
             * Constructor
             *
             */
            Functor3 ( METHOD m, 
                       CLASS *o, 
                       T0 p0, 
                       T1 p1, 
                       T2 p2 )
            : m_param0( p0 ), 
              m_param1( p1 ), 
              m_param2( p2 )
            {
                m_object = o;
                m_method = m;
            }

            /**
             * Copy constructor
             *
             */
            Functor3 ( const Functor3 &f )
            : m_param0( f.m_param0 ), 
              m_param1( f.m_param1 ), 
              m_param2( f.m_param2 )
            {
                m_object = f.m_object;
                m_method = f.m_method;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                (m_object->*m_method)( m_param0, m_param1, m_param2 );
            }
        };

        template <typename CLASS, typename T0, typename T1, typename T2, typename T3>
        class Functor4 : public cFunctor
        {
        private:
            typedef void (CLASS::*METHOD) ( T0, T1, T2, T3 );
            CLASS*  m_object;
            METHOD  m_method;
            T0      m_param0;
            T1      m_param1;
            T2      m_param2;
            T3      m_param3;

        public:
            /**
             * Constructor
             *
             */
            Functor4 ( METHOD m, 
                       CLASS *o, 
                       T0 p0, 
                       T1 p1, 
                       T2 p2, 
                       T3 p3 )
            : m_param0( p0 ), 
              m_param1( p1 ), 
              m_param2( p2 ), 
              m_param3( p3 )
            {
                m_object = o;
                m_method = m;
            }

            /**
             * Copy constructor
             *
             */
            Functor4 ( const Functor4 &f )
            : m_param0( f.m_param0 ), 
              m_param1( f.m_param1 ), 
              m_param2( f.m_param2 ), 
              m_param3( f.m_param3 )
            {
                m_object = f.m_object;
                m_method = f.m_method;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                (m_object->*m_method)( m_param0, m_param1, m_param2, m_param3 );
            }
        };
        

        class Functorf0 : public cFunctor
        {
        private:
            typedef void (*FUNCT) ( void );
            FUNCT   m_funct;

        public:
            /**
             * Constructor
             *
             */
            Functorf0 ( FUNCT f )
            {
                m_funct = f;
            }

            /**
             * Copy constructor
             *
             */
			Functorf0 ( const Functorf0 &f ) : cFunctor()
            {
                m_funct = f.m_funct;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                m_funct( );
            }
        };

        template <typename T0>
        class Functorf1 : public cFunctor
        {
        private:
            typedef void (*FUNCT) ( T0 );
            FUNCT   m_funct;
            T0		m_param0;

        public:
            /**
             * Constructor
             *
             */
            Functorf1 ( FUNCT f, T0 p0 )
			: m_param0( p0 )
            {
                m_funct = f;
            }

            /**
             * Copy constructor
             *
             */
            Functorf1 ( const Functorf1 &f )
			: m_param0( f.m_param0 )
            {
                m_funct = f.m_funct;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                m_funct( m_param0 );
            }
        };

        template <typename T0, typename T1>
        class Functorf2 : public cFunctor
        {
        private:
            typedef void (*FUNCT) ( T0, T1 );
            FUNCT   m_funct;
            T0      m_param0;
            T1      m_param1;

        public:
            /**
             * Constructor
             *
             */
            Functorf2 ( FUNCT f, T0 p0, T1 p1 )
            : m_param0( p0 ),
              m_param1( p1 )
            {
                m_funct = f;
            }

            /**
             * Copy constructor
             *
             */
            Functorf2 ( const Functorf2 &f )
            : m_param0( f.m_param0 ),
              m_param1( f.m_param1 )
            {
                m_funct = f.m_funct;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                m_funct( m_param0, m_param1 );
            }
        };

        template <typename T0, typename T1, typename T2>
        class Functorf3 : public cFunctor
        {
        private:
            typedef void (*FUNCT) ( T0, T1, T2 );
            FUNCT   m_funct;
            T0      m_param0;
            T1      m_param1;
            T2      m_param2;

        public:
            /**
             * Constructor
             *
             */
            Functorf3 ( FUNCT f, T0 p0, T1 p1, T2 p2 )
            : m_param0( p0 ),
              m_param1( p1 ),
              m_param2( p2 )
            {
                m_funct = f;
            }

            /**
             * Copy constructor
             *
             */
            Functorf3 ( const Functorf3 &f )
            : m_param0( f.m_param0 ),
              m_param1( f.m_param1 ),
              m_param2( f.m_param2 )
            {
                m_funct = f.m_funct;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                m_funct( m_param0, m_param1, m_param2 );
            }
        };

        template <typename T0, typename T1, typename T2, typename T3>
        class Functorf4 : public cFunctor
        {
        private:
            typedef void (*FUNCT) ( T0, T1, T2, T3 );
            FUNCT   m_funct;
            T0      m_param0;
            T1      m_param1;
            T2      m_param2;
            T3      m_param3;

        public:
            /**
             * Constructor
             *
             */
            Functorf4 ( FUNCT f, T0 p0, T1 p1, T2 p2, T3 p3 )
            : m_param0( p0 ),
              m_param1( p1 ),
              m_param2( p2 ),
              m_param3( p3 )
            {
                m_funct = f;
            }

            /**
             * Copy constructor
             *
             */
            Functorf4 ( const Functorf4 &f )
            : m_param0( f.m_param0 ),
              m_param1( f.m_param1 ),
              m_param2( f.m_param2 ),
              m_param3( f.m_param3 )
            {
                m_funct = f.m_funct;
            }

            /**
             * Invokes the function/method that the functor wraps
             *
             */
            virtual void operator () ( void )
            {
                m_funct( m_param0, m_param1, m_param2, m_param3 );
            }
        };



        template <typename CLASS>
        cFunctor* bind ( void (CLASS::*m) ( void ), CLASS *o )
        {
            return new Functor0<CLASS>( m, o );
        }

        template <typename CLASS, typename T0>
        cFunctor* bind ( void (CLASS::*m) ( T0 ), CLASS *o, T0 p0 )
        {
            return new Functor1<CLASS, T0>( m, o, p0 );
        }

        template <typename CLASS, typename T0, typename T1>
        cFunctor* bind ( void (CLASS::*m) ( T0, T1 ), CLASS *o, T0 p0, T1 p1 )
        {
            return new Functor2<CLASS, T0, T1>( m, o, p0, p1 );
        }

        template <typename CLASS, typename T0, typename T1, typename T2>
        cFunctor* bind ( void (CLASS::*m) ( T0, T1, T2 ), CLASS *o, T0 p0, T1 p1, T2 p2 )
        {
            return new Functor3<CLASS, T0, T1, T2>( m, o, p0, p1, p2 );
        }

        template <typename CLASS, typename T0, typename T1, typename T2, typename T3>
        cFunctor* bind ( void (CLASS::*m) ( T0, T1, T2, T3 ), CLASS *o, T0 p0, T1 p1, T2 p2, T3 p3 )
        {
            return new Functor4<CLASS, T0, T1, T2, T3>( m, o, p0, p1, p2, p3 );
        }
        
        
        template <int T>
        cFunctor* bind ( void (*f) ( void ) )
        {
            return new Functorf0( f );
        }

        template <typename T0>
        cFunctor* bind ( void (*f) ( T0 ), T0 p0 )
        {
            return new Functorf1<T0>( f, p0 );
        }

        template <typename T0, typename T1>
        cFunctor* bind ( void (*f) ( T0, T1 ), T0 p0, T1 p1 )
        {
            return new Functorf2<T0, T1>( f, p0, p1 );
        }

        template <typename T0, typename T1, typename T2>
        cFunctor* bind ( void (*f) ( T0, T1, T2 ), T0 p0, T1 p1, T2 p2 )
        {
            return new Functorf3<T0, T1, T2>( f, p0, p1, p2 );
        }

        template <typename T0, typename T1, typename T2, typename T3>
        cFunctor* bind ( void (*f) ( T0, T1, T2, T3 ), T0 p0, T1 p1, T2 p2, T3 p3 )
        {
            return new Functorf4<T0, T1, T2, T3>( f, p0, p1, p2, p3 );
        }
}
	// namespace


#endif	
